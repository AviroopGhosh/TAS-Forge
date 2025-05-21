%% generate_omnetpp_ned_file.m 
% Description: This script is used to generate the ned file to load into OMNeT++
% Dependencies: run generate_omnetpp_files
% Output: generated_topology.ned

%% Load the graph previously generated

% Generate error if no graph
if ~exist('G', 'var')
    error('!!! Graph has not been generated yet !!!');
end

% Plot the graph and get the handle to the plot
figure(2)
h = plot(G, 'Layout', 'auto', 'LineWidth',3);  
h.ArrowSize = 12;  
h.NodeFontSize = 12; 

%% Scale the parameters accordingly

% Set the scales for x-y values to scale the topology
x_scale = [1000, 6500];
y_scale = [1000, 6000];

% Set the scales for the display area in the ned file
x_disp_scale = 9000;
y_disp_scale = 9000;

if lt(x_disp_scale, max(x_scale)) || lt(y_disp_scale, max(y_scale))
    error('!!! Display area must be greater than  !!!');
end

% Extract node positions
node_names  = G.Nodes.Name;
x_positions = h.XData;
y_positions = h.YData;

% % Create a map to store node positions
x_old_position = x_positions;
y_old_position = y_positions;
node_positions = containers.Map();  % Initialize an empty map

% Scale the x-range
for i = 1:length(x_positions)
    var = x_positions(i);
    num = (var - min(x_old_position)) * max(x_scale);
    den =  max(x_old_position) - min(x_old_position);

    x_positions(i) = num/den + min(x_scale);
end

% Scale the x-range
for i = 1:length(y_positions)
    var = y_positions(i);
    num = (var - min(y_old_position)) * max(y_scale);
    den =  max(y_old_position) - min(y_old_position);

    y_positions(i) = num/den + min(y_scale);
end

% Fill the map with node positions
for i = 1:length(node_names)
    node_positions(node_names{i}) = [x_positions(i), y_positions(i)];
end

%% Write the file output

dirName        = OMNETppDir; % Directory to store
outputFileName = 'generated_topology.ned'; % File output name 
nedFolderFile  = strcat(dirName,'/',outputFileName); % Total output

% Open the file for writing
fileID = fopen(nedFolderFile, 'w');

% Write the header part of the .ned file
% fprintf(fileID, 'package TSN_Multi_Stream;\n\n');
fprintf(fileID, 'import inet.networks.base.WiredNetworkBase;\n');
fprintf(fileID, 'import inet.node.ethernet.Eth1G;\n');
fprintf(fileID, 'import inet.node.ethernet.EthernetSwitch;\n');
fprintf(fileID, 'import inet.node.tsn.TsnSwitch;\n');
fprintf(fileID, 'import inet.node.inet.StandardHost;\n');
fprintf(fileID, 'import inet.node.tsn.TsnDevice;\n\n');
fprintf(fileID, 'network TS_network extends WiredNetworkBase\n');
fprintf(fileID, '{\n');
fprintf(fileID, '    @display("bgb=%d,%d");\n',x_disp_scale,y_disp_scale);
fprintf(fileID, '    submodules:\n');

% Write the submodules part using the node positions
for i = 1:size(G.Edges, 1)
    src = G.Edges.EndNodes{i, 1};
    dst = G.Edges.EndNodes{i, 2};
    
    % Add source module if not already added
    if isKey(node_positions, src)
        pos = node_positions(src);
        if startsWith(src,'switch')
            fprintf(fileID, '        %s: TsnSwitch {\n', src);
        else
            fprintf(fileID, '        %s: TsnDevice {\n', src);
        end
        fprintf(fileID, '            @display("p=%.2f,%.2f");\n', pos(1), pos(2));
        fprintf(fileID, '        }\n');
        remove(node_positions, src);
    end
    
    % Add destination module if not already added
    if isKey(node_positions, dst)
        pos = node_positions(dst);
        if startsWith(dst,'switch')
            fprintf(fileID, '        %s: TsnSwitch {\n', dst);
        else
            fprintf(fileID, '        %s: TsnDevice {\n', dst);
        end
        fprintf(fileID, '            @display("p=%.2f,%.2f");\n', pos(1), pos(2));
        fprintf(fileID, '        }\n');
        remove(node_positions, dst);
    end
end

fprintf(fileID, '    connections:\n');

% Write the connections part
for i = 1:size(G.Edges, 1)
    src = G.Edges.EndNodes{i, 1};
    dst = G.Edges.EndNodes{i, 2};
    fprintf(fileID, '        %s.ethg++ <--> Eth1G <--> %s.ethg++;\n', src, dst);
end

fprintf(fileID, '}\n');

% Close the file
fclose(fileID);

fprintf('NED file %s generated successfully in directory %s.\n', outputFileName, dirName);
