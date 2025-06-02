%% analyze_omnet_results.m
% Description: Load the results from OMNeT++ and analyze the results
% Dependencies: OMNeT++ simulation and file extraction,
% generate_omnetpp_files.m
% Output: stream_data_output.csv

%% Load CSV Files Generated from OMNeT++
inputfilename = 'results.csv';

omnet_data = readtable(inputfilename, 'VariableNamingRule', 'preserve'); % Load input data from OMNeT++ results
omnet_headers = omnet_data.Properties.VariableNames; % Headers for the omnet_data.csv file

network_data = readtable('network_data.csv', 'VariableNamingRule', 'preserve'); % Load network configuration data

stream_data = readtable('stream_data.csv', 'VariableNamingRule', 'preserve'); % Load stream configuration data

%% Initialize Variables and Error Check
numStreams = size(omnet_data, 2) / 2; % Determine the number of streams (every 2 columns correspond to a stream)
streamData = cell(numStreams, 10); % Initialize cell array to store stream data
mt = network_data.('Macrotick');
num_streamID = max(stream_data.("Stream ID"));
unit = 1e-6; % Set units to us

% Error check: Validate that stream IDs match the expected number of streams
if num_streamID ~= numStreams
    error('!!! Number of streams does not match expected values. Please re-check results. !!!');
end

%% Scheduler Input Validation (if required)
% Collect and validate scheduler name from user input
if ~exist('scheduler_input', 'var') || ~strcmp(scheduler_input, 'WCA') && ~strcmp(scheduler_input, 'WCD') ...
        && ~strcmp(scheduler_input, 'NCA') && ~strcmp(scheduler_input, 'NCD')
    error('!!! Scheduler type not selected, regenerate GCLs. !!!');
end

%% Sorting phase: Sort based on sink app and stream_data.csv

% Check if the OMNeT++ files have been executed
if ~exist("appIndex_sink","var")
    error('!!! The OMNeT++ files have not been executed. !!!')
end

omnet_data_var = zeros;
noStreams = size(stream_data,1); % Number of streams
sinkAppList = strings(noStreams,1); % Initialize as string array of sinks

for i = 1:noStreams
    route_path = strsplit(stream_data.Route{i},',');
    sink_device = route_path(end);
    sinkAppList(i) = sprintf('%s.app[%d]',string(sink_device),appIndex_sink(i));
end

omnet_data_sorted = table(); %Initialize the omnet data for sorting
index = 1;

for i = 1:noStreams
    
    current_index = find(contains(omnet_headers,sinkAppList(i)));
    % Extract the two relevant columns
    selected_data = omnet_data(:, current_index:current_index+1);

    % Assign to the output table using dynamic column indexing
    omnet_data_sorted(:, index:index+1) = selected_data;

    index = index + 2;
end

%% Compute Statistics for Each Stream
for stream_idx = 1:numStreams
    var = stream_data.('Stream ID')(stream_idx); % Extract stream ID
    e2e_latency = omnet_data_sorted{2:end, stream_idx * 2};  % Extract end-to-end latency column for the stream
    
    % Calculate latency metrics
    measured_min_e2e_latency = min(e2e_latency) / unit; % Convert to microseconds
    measured_max_e2e_latency = max(e2e_latency) / unit; % Convert to microseconds
    jitter = measured_max_e2e_latency - measured_min_e2e_latency;

    % Retrieve additional stream data from the stream configuration
    route = stream_data.('Route'){var}; % Route as string or cell array
    periodicity = stream_data.('Periodicity')(var) * mt / unit; % Convert periodicity to microseconds
    payload = stream_data.('Payload Bytes')(var);
    min_e2e_latency = stream_data.('Min e2e latency')(var) * mt / unit;

    % Calculate analytical latencies based on selected scheduler
    if strcmp(scheduler_input, 'NCD') 
        latency_output = analytical_latency_NCD(route, min_e2e_latency, network_data.('Sync Periodicity'),...
            network_data.('Macrotick'), stream_data.('Number of hops')(var),unit);
        analytical_min_e2e_latency = latency_output(:,1);
        analytical_max_e2e_latency = latency_output(:,2);
    elseif strcmp(scheduler_input, 'WCD')
        % Calculate for WCD scheduler
        n_hops = stream_data.('Number of hops')(var);
        n_SW = n_hops - 1;
        delta = network_data.("Delta");
        mt = network_data.('Macrotick');
        adj = n_SW * mt / unit; % Adjustment factor for macrotick
        analytical_min_e2e_latency = min_e2e_latency + (n_SW - 1) * delta * mt / unit;
        analytical_max_e2e_latency = min_e2e_latency + (n_SW + 1) * delta * mt / unit + adj;
    else
        analytical_min_e2e_latency = min_e2e_latency;
        analytical_max_e2e_latency = min_e2e_latency;
    end

    % Store calculated values for each stream
    streamData(stream_idx, :) = {var, route, periodicity, payload, round(min_e2e_latency,2), ...
        round(analytical_min_e2e_latency,2), round(analytical_max_e2e_latency,2),...
        round(measured_min_e2e_latency,2), round(measured_max_e2e_latency,2), round(jitter,2)};
end

%% Output Data to CSV
% Define column headers and create table for export
headers = {'Stream ID', 'Route', 'Periodicity (us)', 'Payload (Bytes)', 'Min E2E Latency (us)',...
    'Analytical Min E2E Latency (us)', 'Analytical Max E2E Latency (us)',...
    'Measured Min E2E Latency (us)', 'Measured Max E2E Latency (us)', 'Jitter (us)'};
output_table = cell2table(streamData, 'VariableNames', headers);
output_filename = strcat('stream_data_output_',scheduler_input,'.csv'); % Specify output filename
writetable(output_table, output_filename); % Write to CSV
fprintf('Results saved to %s\n', output_filename);

%% Sort and Rearrange Data by Number of Hops
% Load the CSV file
filename = output_filename;
data = readtable(filename);

% Assuming 'Route' contains the list of devices (as comma-separated strings)
% and 'SourceID' contains the source identifier

% Step 1: Split the 'Route' column by commas and calculate the number of devices in each route
device_count = cellfun(@(x) numel(strsplit(x, ',')), data.Route);
% Step 2: Add the device count as a new column to the table
data.DeviceCount = device_count - 1;
% Step 3: Sort first by the number of devices (DeviceCount) 
sorted_data = sortrows(data, {'DeviceCount'});
% Optionally save the sorted data to a new CSV file
writetable(sorted_data, output_filename);
% Notify
fprintf('Results updated to %s\n', output_filename);

%% Analytical Latency Calculation for NCD Scheduler
% Define analytical latency function for NCD scheduler (calculates min and max latency based on synchronization data)
function NCD_scheduler_latencies = analytical_latency_NCD(route, min_e2e_latency, T_sync, mt, n_hops,unit)
    nodeData = readtable('node_data.csv', 'VariableNamingRule', 'preserve'); % Load node data
    node_data = nodeData.Node_Name;
    clock_data = nodeData.Clock_Drift;

    % Retrieve GM, source, and last switch clock drift information
    GM1_id = strcmp(node_data, 'GM1');
    p_GM1 = clock_data(GM1_id);
    device_route = strsplit(route, ',');
    src_device_id = strcmp(device_route(1), node_data) == 1;
    last_sw_id = strcmp(device_route(end-1), node_data) == 1;
    p_src = clock_data(src_device_id);
    p_last_sw = clock_data(last_sw_id);

    % Compute queuing delay based on clock drift along route
    Q1 = 0;
    for i = 2:length(device_route)-1
        current_node_id = find(strcmp(device_route(i), node_data) == 1);
        prev_node_id = find(strcmp(device_route(i-1), node_data) == 1);
        queue1 = abs(clock_data(current_node_id) - clock_data(prev_node_id)) * T_sync;
        queue2 = abs(clock_data(current_node_id) - p_GM1) * T_sync;
        queue3 = abs(clock_data(prev_node_id) - p_GM1) * T_sync * ~startsWith(node_data(prev_node_id), 'source');
        Q1 = Q1 + max([queue1, queue2, queue3]);
    end
    Q1 = Q1 * mt / unit;

    % Calculate analytical latencies
    min_latency_adjust = min([0, -(p_last_sw - p_src) * T_sync, -(p_last_sw - p_GM1) * T_sync, -(p_GM1 - p_src) * T_sync]);
    max_latency_adjust = max([0, -(p_last_sw - p_src) * T_sync, -(p_last_sw - p_GM1) * T_sync, -(p_GM1 - p_src) * T_sync]);
    analytical_min_e2e_latency = min_e2e_latency + Q1 + min_latency_adjust * mt / 1e-6 - (n_hops - 1) * mt / unit;
    analytical_max_e2e_latency = min_e2e_latency + Q1 + max_latency_adjust * mt / 1e-6 + (n_hops - 1) * mt / unit;
    
    NCD_scheduler_latencies = [analytical_min_e2e_latency, analytical_max_e2e_latency];
end
