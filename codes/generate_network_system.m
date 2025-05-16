close all
clear all
clc

%% generate_network_system.m
% Description: This is the starting file used to generate 
% the network graph, stream and network information
% Dependences: User defined inputs: number of sources, sinks and switches
% Outputs: network_data.csv, node_data.csv, output_GCL_matrix.txt,
% stream_data.csv, CPLEX_Code_Output directory

%% Enter the number of devices in the network by device type
input_network_system = inputdlg({'Number of sources', 'Number of sinks', 'Number of switches'},...
    'Devices in network by type', [1 50; 1 50; 1 50]);

input_list  = str2double(input_network_system);
num_src     = input_list(1);
num_sink    = input_list(2);
num_switch  = input_list(3);
num_GM      = 1; % Assign the placement of GM in the graph

%% Form the graph of the network
G = generate_linear_topology_graph(num_switch,num_src,num_sink,num_GM);

edgeTable   = G.Edges;
adjNodes    = edgeTable.EndNodes(:,2);    % Adjacent nodes
sinks       = adjNodes(startsWith(adjNodes, 'sink'));

numSinks    = numel(sinks);
sinkNumbers = cellfun(@(x) str2double(regexp(x, '\d+', 'match')), sinks, 'UniformOutput', true);

% Do not proceed if any sink is connected to 2 or more switches
if ne(length(sinkNumbers),length(unique(sinkNumbers)))
    error('!!! Not enough switches to make unique connections to each sink !!!');
end

numNodes   = numel(G.Nodes); %Number of nodes in the network

% Define the routes from sources to sink
routes = {[]};

isEmpty = cellfun(@isempty, routes); %If there are any empty elements in the routes

while ge(sum(isEmpty),1)
% Pair-up the source and sink to form routes
path_vector = function_generate_routes(G.Edges);
    for i = 1:size(path_vector,1)
        routes{i} = shortestpath(G,path_vector{i,1},path_vector{i,2});
    end

    isEmpty = cellfun(@isempty, routes); %Rerun if there are any empty elements in routes

end

% Count the number of sources per route
allSources = horzcat(routes{:});
srcs = allSources(contains(allSources, 'source'));
[uniqueSources, ~, idx] = unique(srcs);
sourceCounts = accumarray(idx, 1);
    
src_repeats = sum(ge(sourceCounts,3));

% Generate the topology
if ne(src_repeats,0)
    G = generate_linear_topology_graph(num_switch,num_src,num_sink,num_GM);
end

numRoutes = size(routes,2); %Number of routes/streams

% Sort the routes based on the number of hops
route_lengths = cellfun(@length, routes);
% Sort the routes based on the number of devices in each route
[~, sorted_indices] = sort(route_lengths);  % Sort route lengths in ascending order
% Re-arrange the original cell array based on sorted indices
routes = routes(sorted_indices);

%% List of network parameters (--- User-configurable network parameters ---)

payload = 100; %Payload in bytes for frames
data    = zeros; %Intialize the data in bytes

for i = 1:length(payload)
    UDP_header      = 28; % UDP header in bytes
    Ether_header    = 26; % Ethernet header in bytes
    data(i) = payload(i) + UDP_header + Ether_header;
end

prop_delay  = 50e-9; %Propagation delay
proc_delay  = 1550e-9; %Processing delay
data_rate   = 1e9; %Bitrate 
guard_band  = 0e-6; % Guard band duration 

data_payload    = zeros; %Initialize the data per stream
payload_bytes   = zeros; %Payload in bytes
trans_delay     = zeros; %Trans delay for each stream


for i = 1:numRoutes
    data_payload(i)     = 8*data(randi(length(data),1)); %Randomly assing the data per stream
    payload_bytes(i)    = data_payload(i)/8 - (UDP_header + Ether_header); %Calculate the payload in bytes
    trans_delay(i)      = (data_payload(i))/data_rate; %Transmission delay for stream
    trans_delay(i)      = trans_delay(i) + guard_band; %Include guard-band to the tranmission duration
end

min_e2e_latency = zeros; %Assign the e2e latency for stream
L               = zeros; %Calculate the L values
numDevices      = zeros; %Number of devices on route

for i = 1:numRoutes
    numDevices(i)   = size(routes{1,i},2);
    min_e2e_latency(i)  = (numDevices(i) -1)*trans_delay(i) + (numDevices(i) -1)*prop_delay...
        + (numDevices(i) -2)*proc_delay;
    L(i) = trans_delay(i) + prop_delay + proc_delay;
end

%% Clock parameter values (--- User-configurable synchronization parameters ---)

p_range = -100:100;   %Clock drift range in ppm
T_sync = 0.125; %Synchronization periodicity

p = zeros;

for i = 1:numNodes-1
    p(i) = p_range(randi(length(p_range))); %Randomly assign clock drift values to each node
end

p(numNodes) = 0; %Clock drift value for GM

%Convert from ppm to us
p_range = -p_range.*1e-6;
p = p.*1e-6;

%Calculate delta-parameter
delta   = (abs(max(p_range)) + abs(min(p_range)))*T_sync;

%Convert all relevant data to unit of mts and then list the table
T0 = table(G.Nodes.Name, p', 'VariableNames', {'Node_Name', 'Clock_Drift'});

%Write the table to a CSV file
filename = 'node_data.csv';
writetable(T0, filename);

fprintf('Node output file "node_data.csv" has been created.\n');

mt = 0.1e-6; %Macrotick value

%% Time-period and hyper-period (--- User-configurable timing parameters ---)

T_period    = [100, 150, 300]*1e-6; %Timeperiods to select from for each stream
T_period_mt = T_period./mt; %Timeperiod in mts

hp  = round(T_period_mt(1)); %Round off hyperperiod

if gt(length(T_period_mt),1)
    for i = 2:length(T_period)
        hp = lcm(hp,round(T_period_mt(i))); %Calculate the hp for the network
    end
end

T_streams   = zeros; %Stream periodicities
repeats_hp  = zeros; %Repeats within the hp
 
for i = 1:numRoutes
    T_streams(i)    = T_period(randi(length(T_period)));  %The periodicity of streams
    repeats_hp(i)   = round(hp/T_streams(i))*mt; %The repetations specified
end

%% Compile all the network data and convert to csv

%Convert all relevant data to unit of mts and then list the table
T1 = table(numRoutes, hp, mt, delta/mt, prop_delay/mt, proc_delay/mt, T_sync/mt,...
    'VariableNames', {'NumStreams', 'Hyperperiod', 'Macrotick', 'Delta', 'Propagation Delay', 'Processing Delay', 'Sync Periodicity'});

%Write the table to a CSV file
filename = 'network_data.csv';
writetable(T1, filename);

fprintf('Network output file "network_data.csv" has been created.\n');

%% Compile all the stream and convert to csv
deadline = T_streams; %Set deadline to stream periodicity

%Convert all relevant data to unit of mts and then list the table
T2 = table((1:numRoutes)', routes', T_streams'./mt, repeats_hp', deadline'./mt, min_e2e_latency'./mt, ...
    trans_delay'./mt, L'./mt, (payload_bytes)',(cellfun(@length,routes)-1)',...
    'VariableNames', {'Stream ID','Route', 'Periodicity', 'Repetitions', 'Deadlines', 'Min e2e latency',...
    'Transmission delay', 'L value', 'Payload Bytes', 'Number of hops'});

%Write the table to a CSV file
filename = 'stream_data.csv';
writetable(T2, filename);

fprintf('Stream output file "stream_data.csv" has been created.\n');

%% Generate the topology map
generate_topology = function_generate_topology_map(G, routes);

if eq(generate_topology,1)
    fprintf('Port connections output file "port_connections.csv" has been created.\n');
else
    error('!!! Topology connection port failed !!!');
end

%% Execute all the CPLEX file generators

if ~exist('CPLEX_Code_Output','dir')
    mkdir CPLEX_Code_Output
    fprintf('Directory created for storing CPLEX codes.\n');
end

run('generate_CPLEX_code_WCD');
run('generate_CPLEX_code_NCD');
run('generate_CPLEX_code_WCA');
run('generate_CPLEX_code_NCA');

%% %% Description: This is a linear topology function that generates graphs and routes
function output = generate_linear_topology_graph(num_switch,num_src,num_sink,num_GM)

%% Create a directed graph with no edges initially
G = digraph;

% Create switch node names
nodeNames_switch = cell(1, num_switch);
for i = 1:num_switch
    nodeNames_switch{i} = sprintf('switch%d', i);
end

% Create sources node names
nodeNames_sources = cell(1, num_src);
for i = 1:num_src
    nodeNames_sources{i} = sprintf('source%d', i);
end

% Create sinks node names
nodeNames_sink = cell(1, num_sink);
for i = 1:num_sink
    nodeNames_sink{i} = sprintf('sink%d', i);
end

% Create GM node name
nodeNames_GM = cell(1, num_GM);
for i = 1:num_GM
    nodeNames_GM{i} = sprintf('GM%d', i);
end

% Add nodes to the graph with Switch names, sources names, and sinks names
G = addnode(G, [nodeNames_switch, nodeNames_sources, nodeNames_sink, nodeNames_GM]);

% Use directed edges to connect the switches together and create a linear topology
for i = 1:num_switch - 1
    G = addedge(G, nodeNames_switch{i}, nodeNames_switch{i + 1});
end

% Connect at least one source to the first switch before the loop
if num_src > 0
    G = addedge(G, nodeNames_sources{1}, nodeNames_switch{1});
end

% This threshold creates a switch that separates the sources from the sinks
sw_threshold = floor(num_switch / 2);

% Connect additional sources to the switches in increasing order
srcCounter = 2; % Start from the second source if available
for i = 1:num_switch
    if srcCounter > num_src
        break;  
    end
    numSourcesPerSwitch = randi([1, 3]); % Ensure each switch connects to at least one source
    for j = 1:numSourcesPerSwitch
        if srcCounter <= num_src
            G = addedge(G, nodeNames_sources{srcCounter}, nodeNames_switch{i});
            srcCounter = srcCounter + 1;
        end
    end
end

% Ensure all sources are connected to a switch
for i = srcCounter:num_src
    switchIdx = mod(i - 1, num_switch) + 1;  
    G = addedge(G, nodeNames_sources{i}, nodeNames_switch{switchIdx});
end

% Connect the sinks to the switches in increasing order starting from the switch threshold
sinkCounter = 1;
for i = (sw_threshold + 1):num_switch
    if sinkCounter > num_sink
        break; 
    end
    G = addedge(G, nodeNames_switch{i}, nodeNames_sink{sinkCounter});
    sinkCounter = sinkCounter + 1;
end

% Ensure all sinks are connected to a switch
for i = sinkCounter:num_sink
    switchIdx = mod(i - 1, num_switch - sw_threshold) + sw_threshold + 1;
    G = addedge(G, nodeNames_switch{switchIdx}, nodeNames_sink{i});
end

% Check if the last switch is connected to at least one sink
if isempty(outedges(G, nodeNames_switch{num_switch}))
    % Connect the last switch to a random sink
    G = addedge(G, nodeNames_switch{num_switch}, nodeNames_sink{randi(num_sink)});
end

% Connect GM to a random switch
for i = 1:num_GM
    G = addedge(G, nodeNames_GM{i}, nodeNames_switch{randi([1, num_switch])});
end

%% Visualize the graph
% Create a figure window
figure;

% Plot the graph with a layered layout
h = plot(G, 'Layout', 'force');

% Set properties for nodes and edges
h.NodeFontSize = 14;   % Increase node font size for readability
h.MarkerSize = 10;     % Set node marker size
h.LineWidth = 3;       % Set edge line width for visibility
h.ArrowSize = 12;      % Increase arrow size for better visibility
h.EdgeColor = 'k';     % Set edge color to black
h.LineStyle = '-';     % Set edge style to solid

% Highlight different types of nodes with specific colors
highlight(h, nodeNames_switch, 'NodeColor', 'blue', 'Marker', 's');   % Switch nodes in square markers
highlight(h, nodeNames_sources, 'NodeColor', 'red', 'Marker', '^');   % Source nodes in triangle-up markers
highlight(h, nodeNames_sink, 'NodeColor', 'green', 'Marker', 'o');    % Sink nodes in circle markers
highlight(h, nodeNames_GM, 'NodeColor', 'magenta', 'Marker', 'p');    % GM nodes in pentagram markers


% Add labels to all nodes
labelnode(h, 1:(num_switch + num_src + num_sink + num_GM), ...
    [nodeNames_switch, nodeNames_sources, nodeNames_sink, nodeNames_GM]);


output = G; % Output the graph properties and routes
end 
