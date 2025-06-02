%% generate_GCL_output.m
% Description: This script obtains the input text file from
% CPLEX offsets and output the GCLs in microseconds
% Dependences: Executing CPLEX files, input_cplex_solution.txt, 
% port_connections.csv, network_data.csv, node_data.csv
% Output: output_GCL_matrix.txt

%% Input prompt 
prompt = 'What scheduler did you select (WCA/WCD/NCA/NCD)?:  ';
scheduler_input = input(prompt, 's'); %Collect the scheduler name as a string

if ~strcmp(scheduler_input,'WCA') && ~strcmp(scheduler_input,'WCD')...
        && ~strcmp(scheduler_input,'NCD') && ~strcmp(scheduler_input,'NCA')
    error('!!! Wrong scheduler selected !!!')
end

%% Read and Evaluate the CPLEX input Text File
filename = ['output_CPLEX_solution_' scheduler_input '.txt'];
fileID = fopen(filename, 'r');
if fileID == -1
    error('Cannot open the file.');
end
fileContent = fread(fileID, '*char')';
fclose(fileID);
eval(fileContent); % Load the offsets into the workspace

if ~exist('switchToStreams', 'var')
    error('Variable switchToStreams is undefined.');
end

%% Check if the decision variables have been loaded correct

% Get the list of variables in the workspace
vars = who;

%Read the topology connections
topologyData = function_read_topology_data('port_connections.csv', 2); 

% Check if all sources are present
for i = 1:size(topologyData, 1)
    
    % Check through all the sources and switches
    if contains(topologyData{i,1},'source') || contains(topologyData{i,1},'switch')
        % Extract the list of stream IDs from the topology data
        listStreams = str2double(strsplit(topologyData{i, 5}));
        
        % Iterate over the streams in the list
        for k = 1:length(listStreams)
            stream_id = listStreams(k);     
            check_decision = strcat('OFF_',string(stream_id),'_',topologyData{i,1});
            if ~sum(contains(vars,check_decision)) && ne(stream_id,0)
                error('!!! The decision variable %s has not been loaded !!!',check_decision)
            end
        end
    end
end

%% Gather the offset from the sources

source_offsets_matrix = cell(0);

src_counter = 0;
% Loop through each row in the topology data
for i = 1:size(topologyData, 1)
    source_offset = [];
    
    % Check if the row corresponds to a source
    if contains(topologyData{i, 1}, 'source')
        % Extract the list of stream IDs from the topology data
        listStreams = str2double(strsplit(topologyData{i, 5}));

        % Iterate over the streams in the list
        for k = 1:length(listStreams)
            stream_id = listStreams(k);
            
            % Search for the corresponding variable in the workspace
            for j = 1:length(vars)
                var_name = vars{j};
                
                % Check if the variable name matches the source and stream ID
                if contains(var_name, 'source')
                    extracted_stream_id = str2double(regexp(var_name, '\d+', 'match', 'once'));
                    
                    % If the stream ID matches, add the value to the source offset
                    if extracted_stream_id == stream_id
%                         disp(['Match found for stream ID: ', num2str(stream_id)]);
                        new_value = eval(var_name);
                        source_offset = [source_offset, new_value];
                        break;  % Break the loop once a match is found
                    end
                end
            end
        end
        
        % Increment the source counter and store the offsets
        src_counter = src_counter + 1;
        source_offsets_matrix{src_counter} = source_offset;
    end
end

% disp('"source_offsets_matrix" has been created.')

%% Initialize a map to store switch values and extract them

topologyData    = function_read_topology_data('port_connections.csv', 2); %Read the topology connections
% Get the list of variables in the workspace
vars = who;

% Generate the GCL offset based on the topology
GCL_offsets_id = cell(0);
stream_offset_id = cell(0);
switch_index = cell(0);

% Run through the topology data
for i = 1:length(topologyData)
    % Gather the list of routes for the switch
    routes_included = str2double(strsplit(topologyData(i,5)));
    switch_offset = []; %Gather stream offset values
    stream_offset = []; %Gather stream ids for the offset
    %Update the offset value based on the following condition
    if startsWith(topologyData(i,1),'switch') && ge(length(routes_included),1)
        stream_offset = str2double(strsplit(topologyData(i,5)));
        % For each of the topology data, compare workspace data
        for k = 1:length(stream_offset)
            for j = 1:length(vars)
                var_name = vars{j};
            
                % Only proceed if the variable is a switch
                if contains(var_name,'switch')
                    % Extract switch id from the variable name
                    switch_id = regexp(var_name, 'switch\d+', 'match', 'once');
                    % Extract stream id from the variable name
                    stream_id = str2double(regexp(var_name, '\d+', 'match', 'once'));
                    new_value = eval(var_name); %Extract value from the offset
                    if strcmp(switch_id,topologyData(i,1)) && eq(stream_id,stream_offset(k))
                        switch_offset = [switch_offset, new_value];
                        switch_index{i} = switch_id; % Store the switch for the corresponding GCL
                    end
                end
            end
        end
    end
    GCL_offsets_id{i} = switch_offset; %Update the GCL offset values
    stream_offset_id{i} = (stream_offset); %Update the stream value
end

GCL_offsets_id = GCL_offsets_id';
stream_offset_id = stream_offset_id';


%% Generate the GCL schedules from the corresponding algorithm

% Load the network_data.csv file with original column names
networkData = readtable('network_data.csv','VariableNamingRule','preserve');

mt  = networkData.('Macrotick'); %Gather the macrotick
GCL_output_matrix = cell(0);
counter = 0;
for i = 1:length(GCL_offsets_id)
    index = i;

    if eq(0,isempty(GCL_offsets_id{i}))
        if strcmp(scheduler_input, 'WCD') || strcmp(scheduler_input, 'NCD')
            % WCD and NCD GCL schedules 
            output_matrix = function_GCL_formation_WCD_NCD(GCL_offsets_id{index},stream_offset_id{index});
            output_matrix = output_matrix.*mt/1e-6; %Convert to macrotick then 1us
        elseif strcmp(scheduler_input, 'WCA')
            % WCA GCL schedules 
            output_matrix = function_GCL_formation_WCA(GCL_offsets_id{index},stream_offset_id{index});
            output_matrix = output_matrix.*mt/1e-6; %Convert to macrotick then 1us
        elseif strcmp(scheduler_input, 'NCA')
            % NCA GCL schedules 
            output_matrix = function_GCL_formation_NCA(GCL_offsets_id{index},stream_offset_id{index},switch_index{index});
            output_matrix = output_matrix.*mt/1e-6; %Convert to macrotick then 1us
        end
        counter = counter + 1;
        GCL_output_matrix{counter} = output_matrix; %GCL output matrix 
    end
end

gate_state_array = cell(0); %Initial gate state 
GCL_matrix = cell(0); %Extract the GCL for the switches

% Iterate over each cell in the input cell array
for i = 1:length(GCL_output_matrix)
    % Extract the 2:end elements and store them in the new cell array for the GCL output
    GCL_matrix{i} = GCL_output_matrix{i}(2:end);
    
    % The first output of the cell matrix is the gate state ON/OFF
    gate_state_array{i} = GCL_output_matrix{i}(1)*1e-6/mt; %Converted from us and mts
end

%% Create a text for the GCL matrix

% Initialize an empty cell array for the output
output_GCL_sw = cell(0);  % The output GCL with us and commas
output_GCL_matrix = cell(0);

% Iterate over each cell in the input cell array
for i = 1:size(GCL_matrix, 1)
    % Append 'us' to each element and store it in the output cell array
    for j = 1:size(GCL_matrix, 2)
        % Get the current cell array
        current_cell = GCL_matrix{i, j};
        
        % Initialize an empty cell array for the current output cell
        output_GCL_sw = cell(1, length(current_cell));
        
        % Iterate over each element in the current cell array
        for k = 1:length(current_cell)
            if k == 1
                % First variable append with '[us,'
                output_GCL_sw{k} = ['[', num2str(current_cell(k)), 'us,'];
            elseif k > 1 && k < length(current_cell)
                % Append 'us,' with the comma
                output_GCL_sw{k} = [num2str(current_cell(k)), 'us,'];
            else
                % last variable append 'us' without the comma
                output_GCL_sw{k} = [num2str(current_cell(k)), 'us]'];
            end
        end
        
        % Store the output cell array in the output cell matrix
        output_GCL_matrix{i, j} = output_GCL_sw;
    end
end

% Open a text file for writing the GCL matrix
fileID = fopen('output_GCL_matrix.txt', 'w');

% Write the contents of the output cell matrix to the text file
for i = 1:length(output_GCL_matrix)
    % Write each element followed by a new line
    fprintf(fileID, '%s\n', cell2mat(output_GCL_matrix{i}));
end

%% Display the schedulability cost

noEgressPort = length(GCL_matrix); %Number of egress ports
scVar = 0; %Variable for sc

for i = 1:noEgressPort
    var_array = GCL_matrix{1,i};
    
    if eq(gate_state_array{i},0) %If gate state is 0
        sc_var = sum(var_array(2:2:end))/sum(var_array);
    elseif eq(gate_state_array{i},1) %If gate state is 1 
        sc_var = sum(var_array(1:2:end))/sum(var_array);
    else
        error('!!! Gate State should be 0 or 1 !!!');
    end
    
    scVar = sc_var + scVar;
end

scValue = scVar/noEgressPort; %The schedulability cost value

%% Closing 

% Close the file
fclose(fileID);

disp('File "output_GCL_matrix.txt" has been created.');
fprintf('\nThe schedulability cost is %g\n\n',scValue);


%% Function to generate GCLs if NCA scheduler is selected

function GCL_schedule = function_GCL_formation_NCA(sw_offsets, switch2streams, switchID)

% switch2streams = switchToStreams{switchID,2}; %Load the stream IDs associated with the switch

% Load the stream_data.csv file with original column names
streamData = readtable('stream_data.csv', 'VariableNamingRule', 'preserve');

% Load the network_data.csv file with original column names
networkData = readtable('network_data.csv','VariableNamingRule','preserve');

% Load the node_data.csv file with original column names
nodeData = readtable('node_data.csv','VariableNamingRule','preserve');

% Decipher the switch from the switchID
node_name   = nodeData.Node_Name; % Gather the node names
node_CD     = nodeData.Clock_Drift; % Clock drift of the node
 
for i = 1:size(nodeData,1)
    % Match the switch ID to the clock drift of the switch
    if startsWith(node_name(i),'switch') && strcmp(switchID,node_name(i))
        p_switch = node_CD(i);
        break
    end
end

for i = 1:size(nodeData,1)
    % Match the switch ID to the clock drift of the switch
    if startsWith(node_name(i),'GM1') 
        p_GM = node_CD(i);
        break
    end
end

GCL_schedule = 0;

% Number of streams in switch
stream_no   = length(switch2streams); %Number of streams in switch
hp          = networkData.('Hyperperiod')(1); %Gather the hyperperiod
T_stream    = streamData.('Periodicity'); %The periodicity of the streams
trans_delay = streamData.('Transmission delay'); %The transmission delay
T_sync = networkData.('Sync Periodicity');

% Initialize the A_matrix from Alog 2
A_matrix    = zeros(stream_no,hp); 

% Generate the A_matrix
for m = 1:stream_no
    
    index = switch2streams(m); %Stream index
    var_route = strsplit(streamData.Route{index},',');

    source_index = var_route(1);

    for i = 1:size(nodeData,1)
    % Match the source ID clock drift value
        if startsWith(node_name(i),'source') && strcmp(string(source_index),node_name(i))
            p_src = node_CD(i);
            break
        end
    end

    for n = 1:hp
        if le(mod((n - sw_offsets(m) - 1),(T_stream(index))) , ceil(ceil(trans_delay(index)) ...
                - min(min(min(0, (p_switch - p_src)), (p_GM - p_src)), (p_switch - p_GM))*T_sync ...
                + max(max(max(0, (p_switch - p_src)), (p_GM - p_src)), (p_switch - p_GM))*T_sync + 2))
            A_matrix(m,n) = 1;
        end
    end

end

% The a array based on the sum of the A_matrix
if eq(stream_no,1)
    a_array = (A_matrix(:,:));  %If there is only one stream going through the switch
else
    a_array = sum(A_matrix(:,:));
end

assignin('base', 'a_array', a_array);

% Check for overlapping conditions
for i = 1:length(a_array)
    if gt(a_array(i),1)
        disp(switch2streams)
        disp(sw_offsets)
        error('!!! There is an overlapping condition in forming GCLs !!!')
        break
    end
end

%The initial state of the schedule for the switch
GCL_initial_state = a_array(1,1);
counter = 1;
GCL_queue_state(counter) = 1;

% Scan the entire hyperperiod

for n = 2:hp

    if eq(a_array(n),a_array(n-1))  %If current value is equal to previous value
        GCL_queue_state(counter) = GCL_queue_state(counter) + 1;
    else
        %If currrent value is not equal to previous value then change
        %period i.e., GCL duration moves from ON/OFF or OFF/ON
        counter = counter + 1;
        GCL_queue_state(counter) = 1;
    end

end

% This is the ensure that ON/OFF durations interleave
if ne(mod(counter,2),0) %Check if the values are even

    counter = counter + 1;
    GCL_queue_state(counter) = 0;

end

SW_initial_state = GCL_initial_state; 

% Return the initial state of the switch and GCL 
GCL_schedule = [SW_initial_state, round((GCL_queue_state),2)];

end

%% Function to generate GCLs if WCA scheduler is selected

function GCL_schedule = function_GCL_formation_WCA(sw_offsets, switch2streams)
% switch2streams = switchToStreams{switchID,2}; %Load the stream IDs associated with the switch

% Load the stream_data.csv file with original column names
streamData = readtable('stream_data.csv', 'VariableNamingRule', 'preserve');

% Load the network_data.csv file with original column names
networkData = readtable('network_data.csv','VariableNamingRule','preserve');

% Number of streams in switch
stream_no   = length(switch2streams); %Number of streams in switch
hp          = networkData.('Hyperperiod')(1); %Gather the hyperperiod
T_stream    = streamData.('Periodicity'); %The periodicity of the streams
trans_delay = streamData.('Transmission delay'); %The transmission delay
delta = networkData.('Delta'); %Obtain the delta parameter

% Initialize the A_matrix from Alog 2
A_matrix    = zeros(stream_no,hp); 

% Generate the A_matrix
for m = 1:stream_no

    index = switch2streams(m); %Stream index

    for n = 1:hp
        if le(mod((n - sw_offsets(m) - 1),(T_stream(index))) , ceil(trans_delay(index) + 2*delta ))
            A_matrix(m,n) = 1;
        end
    end

end

% The a array based on the sum of the A_matrix
if eq(stream_no,1)
    a_array = (A_matrix(:,:));  %If there is only one stream going through the switch
else
    a_array = sum(A_matrix(:,:));
end

% Check for overlapping conditions
for i = 1:length(a_array)
    if gt(a_array(i),1)
        disp(switch2streams)
        disp(sw_offsets)
        error('!!! There is an overlapping condition in forming GCLs !!!')
        break
    end
end

%The initial state of the schedule for the switch
GCL_initial_state = a_array(1,1);
counter = 1;
GCL_queue_state(counter) = 1;

% Scan the entire hyperperiod

for n = 2:hp

    if eq(a_array(n),a_array(n-1))  %If current value is equal to previous value
        GCL_queue_state(counter) = GCL_queue_state(counter) + 1;
    else
        %If currrent value is not equal to previous value then change
        %period i.e., GCL duration moves from ON/OFF or OFF/ON
        counter = counter + 1;
        GCL_queue_state(counter) = 1;
    end

end

% This is the ensure that ON/OFF durations interleave
if ne(mod(counter,2),0) %Check if the values are even

    counter = counter + 1;
    GCL_queue_state(counter) = 0;

end

SW_initial_state = GCL_initial_state; 

% Return the initial state of the switch and GCL 
GCL_schedule = [SW_initial_state, round((GCL_queue_state),2)];


end

%% Function to generate GCLs if WCD or NCD scheduler is selected
function GCL_schedule = function_GCL_formation_WCD_NCD(sw_offsets, switch2streams)

% switch2streams = switchToStreams{switchID,2}; %Load the stream IDs associated with the switch

% Load the stream_data.csv file with original column names
streamData = readtable('stream_data.csv', 'VariableNamingRule', 'preserve');

% Load the network_data.csv file with original column names
networkData = readtable('network_data.csv','VariableNamingRule','preserve');

% Number of streams in switch
stream_no   = length(switch2streams); %Number of streams in switch
hp          = networkData.('Hyperperiod')(1); %Gather the hyperperiod
T_stream    = streamData.('Periodicity'); %The periodicity of the streams
trans_delay = streamData.('Transmission delay'); %The transmission delay

% Initialize the A_matrix from Alog 2
A_matrix    = zeros(stream_no,hp); 

% Generate the A_matrix
for m = 1:stream_no

    index = switch2streams(m); %Stream index

    for n = 1:hp
        if le(mod((n - sw_offsets(m) - 1),(T_stream(index))) , ceil(trans_delay(index)))
            A_matrix(m,n) = 1;
        end
    end

end

% The a array based on the sum of the A_matrix
if eq(stream_no,1)
    a_array = (A_matrix(:,:));  %If there is only one stream going through the switch
else
    a_array = sum(A_matrix(:,:));
end

for i = 1:length(a_array)
    if gt(a_array(i),1)
        disp(sw_offsets)
        error('!!! There is an overlapping condition in forming GCLs !!!')
        break
    end
end
%The initial state of the schedule for the switch
GCL_initial_state = a_array(1,1);

counter = 1;
GCL_queue_state(counter) = 1;

% Scan the entire hyperperiod

for n = 2:hp

    if eq(a_array(n),a_array(n-1))  %If current value is equal to previous value
        GCL_queue_state(counter) = GCL_queue_state(counter) + 1;
    else
        %If currrent value is not equal to previous value then change
        %period i.e., GCL duration moves from ON/OFF or OFF/ON
        counter = counter + 1;
        GCL_queue_state(counter) = 1;
    end

end

% This is the ensure that ON/OFF durations interleave
if ne(mod(counter,2),0) %Check if the values are even

    counter = counter + 1;
    GCL_queue_state(counter) = 0;

end

SW_initial_state = GCL_initial_state; 

% Return the initial state of the switch and GCL 
GCL_schedule = [SW_initial_state, round((GCL_queue_state),2)];

end
