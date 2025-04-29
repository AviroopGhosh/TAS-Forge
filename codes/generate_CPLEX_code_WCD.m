%% generate_CPLEX_code_WCD.m
% Description: The script is used for generating the output file to be 
% executed on CPLEX for the WCD method
% Dependencies: Run generate_network_system.m
% Output: output_CPLEX_code_generator_WCD.txt

%% Initialize and load stream data and create file
% Load the stream_data.csv file with original column names
streamData = readtable('stream_data.csv', 'VariableNamingRule', 'preserve');

% Load the network_data.csv file with original column names
networkData = readtable('network_data.csv','VariableNamingRule','preserve');

% % Display the table's variable names to check how they were read
% disp(streamData.Properties.VariableNames);

% Open a file to write the CPLEX output
outputFile = fopen('CPLEX_Code_Output/output_CPLEX_code_WCD.mod', 'w');

%% Initialize the number of streams

% Number of streams
fprintf(outputFile, '%s', '// Set the number of streams');
NumStreams  = networkData.('NumStreams'); % The number of streams
outputLine = sprintf('\nint num_streams = %d;', NumStreams); % Print the number of streams
fprintf(outputFile, '%s', outputLine);
outputLine = sprintf('\nrange N_streams = 1..num_streams;'); % Print the number of streams
fprintf(outputFile, '%s', outputLine);

%% Stream periodicity and deadline

T_period    = streamData.('Periodicity'); %The periodicity of streams
deadline    = streamData.('Deadlines'); %The deadlines of streams

% Periodicity of traffic
fprintf(outputFile, '\n\n%s', '// The periodicity of streams');
fprintf(outputFile, '\nfloat T_period[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', T_period(i));
    else
        fprintf(outputFile, '%g];', T_period(i)); % No comma but ; after the last element
    end
end

% Deadline of traffic
fprintf(outputFile, '\n\n%s', '// The deadline of streams');
fprintf(outputFile, '\nfloat deadline[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', deadline(i));
    else
        fprintf(outputFile, '%g];', deadline(i)); % No comma but ; after the last element
    end
end

%% Stream hp and repetitions

% Hyperperiod data
fprintf(outputFile, '\n\n%s', '// The hyperperiod of the network');
hp = networkData.('Hyperperiod')(1); % Extract the hyperperiod
outputLine = sprintf('\nfloat hp = %d;', hp); % Print the hyperperiod
fprintf(outputFile, '%s', outputLine);

% Repetitions of stream within the hp
repetitions = streamData.('Repetitions'); %The repetitions of streams
fprintf(outputFile, '\n\n%s', '// The repetitions of streams within the hp');
fprintf(outputFile, '\nint repetitions[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', repetitions(i));
    else
        fprintf(outputFile, '%g];', repetitions(i)); % No comma but ';' after the last element
    end
end

%% Overlapping constraint

k_max = hp/min(T_period);
% k_max = 1;

fprintf(outputFile, '\n\n%s', '// The integer set for overlapping constraint');
outputLine = sprintf('\n// int kmax = %d;', k_max); % Print the hyperperiod
fprintf(outputFile, '%s', outputLine);


%% Identify the switch and corresponding switches

streamIDs = streamData.('Stream ID'); 
routes = streamData.('Route');         

% Initialize a cell array to hold switch-to-stream mappings
switchToStreams = {};

% Loop through each route
for i = 1:length(routes)
    % Split the route into individual nodes
    devices = strsplit(routes{i}, ',');
    
    % Extract the stream ID associated with this route
    streamID = streamIDs(i);
    
    % Identify switches in the route
    switches = devices(startsWith(devices, 'switch'));
    
    % Associate the stream ID with each switch in the route
    for j = 1:length(switches)
        switchID = switches{j};
        
        % Check if the switch already exists in the cell array
        found = false;
        for k = 1:size(switchToStreams, 1)
            if strcmp(switchToStreams{k, 1}, switchID)
                % Append the stream ID to the existing list for this switch
                switchToStreams{k, 2} = [switchToStreams{k, 2}, streamID];
                found = true;
                break;
            end
        end
        
        if ~found
            % If the switch is not found, add a new row with the switch and stream ID
            switchToStreams = [switchToStreams; {switchID, streamID}];
        end
    end
end

%% Clock drift and device timing related parameters
% Delta delay
fprintf(outputFile, '\n\n%s', '// The delta value in the network');
delta = networkData.('Delta')(1); % Extract the delta value
outputLine = sprintf('\nfloat delta = %f;', delta); % Print the Delta
fprintf(outputFile, '%s', outputLine);

%% State the latency related parameters: propagation delay, processing delay, transmission delay, L
% Propgation delay
fprintf(outputFile, '\n\n%s', '// Set the propagation delay');
prop_delay = networkData.('Propagation Delay')(1); % Extract the propgation delay
outputLine = sprintf('\nfloat prop_delay = %f;', prop_delay); % Print the propgation delay
fprintf(outputFile, '%s', outputLine);

% Processing delay
fprintf(outputFile, '\n\n%s', '// Set the processing delay');
proc_delay = networkData.('Processing Delay')(1); % Extract the processing delay
outputLine = sprintf('\n//float proc_delay = %f;', proc_delay); % Print the processing delay
fprintf(outputFile, '%s', outputLine);

% Transmission delay
fprintf(outputFile, '\n\n%s', '// Set the transmission delay');
trans_delay = streamData.('Transmission delay');
fprintf(outputFile, '\nfloat trans_delay[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', trans_delay(i));
    else
        fprintf(outputFile, '%g];', trans_delay(i)); % No comma but ';' after the last element
    end
end

% Transmission delay var: An int value that takes the ceil value with an
% added buffer
fprintf(outputFile, '\n\n%s', '// Set the ceil of the transmission delay');
trans_delay = streamData.('Transmission delay');
fprintf(outputFile, '\nint trans_delay_var[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', ceil(trans_delay(i) + 1));
    else
        fprintf(outputFile, '%g];', ceil(trans_delay(i) + 1)); % No comma but ';' after the last element
    end
end

% L parameter
fprintf(outputFile, '\n\n%s', '// Set the L value per stream');
L = streamData.('L value');
fprintf(outputFile, '\nfloat L[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', L(i));
    else
        fprintf(outputFile, '%g];', L(i)); % No comma but ';' after the last element
    end
end

%% Minimum e2e latency and analytical e2e latency
% Minimum e2e latency
fprintf(outputFile, '\n\n%s', '// Set the minimum e2e latency values per stream');
min_e2e = streamData.('Min e2e latency');
fprintf(outputFile, '\nfloat min_e2e[N_streams] = [');
% Loop over each periodicity and format it
for i = 1:NumStreams
    % Write the periodicity value
    if i < NumStreams
        fprintf(outputFile, '%g, ', min_e2e(i));
    else
        fprintf(outputFile, '%g];', min_e2e(i)); % No comma but ';' after the last element
    end
end

%% Create a list of offsets required
% Determine offsets based on the convention Device_StreamID

fprintf(outputFile, '\n\n%s\n', '// Initialize the list of offsets');
for i = 1:length(routes)
    % Split the route into individual devices
    devices = strsplit(routes{i}, ',');
  
    % Generate the output string for each device in the route
    for j = 1:length(devices) - 1 %Source to last switch
        deviceName = strtrim(devices{j});  % Remove any leading/trailing spaces
        outputLine = sprintf('dvar int+ OFF_%d_%s;\n', i, deviceName);
        
        % Write the output line to the file
        fprintf(outputFile, '%s', outputLine);
    end
end

%% Create a list of relevant end-to-end latency values
% The convention to follow is lambda_StreamID

fprintf(outputFile, '\n\n%s\n', '// Initialize the end-to-end latency');
for i = 1:height(streamData)
    streamID = streamData.('Stream ID')(i);

    outputLine = sprintf('dvar float+ lambda_%d;\n', streamID);

    % Write the output line to the file
    fprintf(outputFile, '%s', outputLine);
end

%% State the minimization problem

fprintf(outputFile, '\n\n%s\n', '// The minimization problem');
% Start writing the minimization expression
fprintf(outputFile, 'minimize ');

% Loop over the terms and create the expression
for i = 1:NumStreams
    if i == 1
        % First term, no leading +
        fprintf(outputFile, '(lambda_%d - min_e2e[%d])', i, i);
    else
        % Subsequent terms, add leading +
        fprintf(outputFile, ' + (lambda_%d - min_e2e[%d])', i, i);
    end
end

% End the expression with a semicolon
fprintf(outputFile, ';\n');

%% Subject to: Start adding the constraints

fprintf(outputFile, '\n%s\n', 'subject to {');

%% The boundary conditions

fprintf(outputFile, '\n%s\n', '// State the boundary conditions, the lower-bound and upper-bound');

for i = 1:height(streamData)
    streamID = streamData.('Stream ID')(i);  % Extract Stream ID
    route = streamData.('Route'){i};         % Extract Route for the stream

    % Split the route into individual devices
    devices = strsplit(route, ',');

    fprintf(outputFile, '\n// Boundary conditions for Stream %d\n', i);
    % Generate the output string for each device in the route
    for j = 1:length(devices) - 1 %Source to last switch
        deviceName = strtrim(devices{j});  % Remove any leading/trailing spaces
        outputLine = sprintf('0 <= OFF_%d_%s <= hp - 1;', streamID, deviceName);
        % Write the output line to the file
        fprintf(outputFile, '%s\n', outputLine);
    end
end

%% Non-overlapping constraint 

fprintf(outputFile, '\n%s\n', '// The overlapping constraint');

topologyData    = function_read_topology_data('port_connections.csv', 2); %Read the topology connections

fprintf(outputFile, '\n%s\n', '// The overlapping constraint: To prevent overlaps from streams from the same source');

for i = 1:length(topologyData)
    % Gather the list of routes
    routes_included = str2double(strsplit(topologyData(i,5)));
    % Device needs to be a switch and have more than one route for the
    % egress port
    if startsWith(topologyData(i,1),'source') && gt(length(routes_included),1)
        sourceID = topologyData(i,1); % The switch in question
        fprintf(outputFile, '\n// The route within %s\n', sourceID);
        for j = 1:length(routes_included)
            for l = j+1:length(routes_included)
                streamID1 = routes_included(j);
                streamID2 = routes_included(l);
                fprintf(outputFile, 'forall(alpha in 0..repetitions[%d]-1, beta in 0..repetitions[%d]-1) {\n', streamID1, streamID2);
                % Write the loop structure for repetitions
                constraint = sprintf('maxl(trans_delay_var[%d],trans_delay_var[%d]) <= abs(OFF_%d_%s - OFF_%d_%s) <= hp - 1;\n', ...
                    streamID1,streamID2,streamID1, sourceID, streamID2, sourceID);
                % Write the constraint to the file
                fprintf(outputFile, '%s', constraint);
                % End of the constraint
                fprintf(outputFile, '}\n');
            end
        end
    end
end

fprintf(outputFile, '\n%s\n', '// The overlapping constraint: To prevent overlaps between streams in the same switch');

for i = 1:length(topologyData)
    % Gather the list of routes
    routes_included = str2double(strsplit(topologyData(i,5)));
    % Device needs to be a switch and have more than one route for the
    % egress port
    if startsWith(topologyData(i,1),'switch') && gt(length(routes_included),1)
        switchID = topologyData(i,1); % The switch in question
        fprintf(outputFile, '\n// Port of %s towards %s\n', switchID, topologyData(i,3));
        % Specify the switch and egress port
        for j = 1:length(routes_included)
            for l = j+1:length(routes_included)
                streamID1 = routes_included(j);
                streamID2 = routes_included(l);
      
                fprintf(outputFile, 'forall(alpha in 0..repetitions[%d]-1, beta in 0..repetitions[%d]-1) {\n', streamID1, streamID2);
                constraint = sprintf('abs((OFF_%d_%s + (alpha - 1)*T_period[%d]) - (OFF_%d_%s + (beta - 1)*T_period[%d])) <= %d*(hp - 1);\n', ...
                    streamID1, switchID, streamID1, streamID2, switchID, streamID2, 1);
                % Write the constraint to the file
                fprintf(outputFile, '%s', constraint);

                % Close the loop structure
                fprintf(outputFile, '}\n');

            end
        end
    end
end

%% Flow transmission constraint 

fprintf(outputFile, '\n%s\n', '// Flow transmission constraint: The difference between consecutive offsets');

% Loop through each stream/route
for i = 1:length(routes)
    % Split the route into individual nodes
    devices = strsplit(routes{i}, ',');
    
    % Identiy the source
    sources = devices(startsWith(devices, 'source'));

    % Identify switches in the route
    switches = devices(startsWith(devices, 'switch'));
    
    fprintf(outputFile, '\n%s%d', '// Stream ', i);
    % Associate the stream ID with each switch in the route
    for j = 1:length(switches)
        if eq(j,1)
            ft_constraint = sprintf('OFF_%d_%s >= OFF_%d_%s + ceil(L[%d] + delta + 1);',i,switches{j},i,sources{1},i);
        else
            ft_constraint = sprintf('OFF_%d_%s >= OFF_%d_%s + ceil(L[%d] + delta + 1);',i,switches{j},i,switches{j-1},i);
        end
    % Write the constraint to the file
    fprintf(outputFile, '\n%s', ft_constraint);
    end
    
end

%% The scheduling duration constraint

fprintf(outputFile, '\n\n%s\n', '// The scheduling duration constraint: Switch schedules should not overlap');

topologyData    = function_read_topology_data('port_connections.csv', 2); %Read the topology connections

for i = 1:length(topologyData)
    % Gather the list of routes
    routes_included = str2double(strsplit(topologyData(i,5)));
    % Device needs to be a switch and have more than one route for the
    % egress port
    if startsWith(topologyData(i,1),'switch') && gt(length(routes_included),1)
        switchID = topologyData(i,1); % The switch in question
        fprintf(outputFile, '// Port of %s towards %s\n', switchID, topologyData(i,3));
        % Specify the switch and egress port
        for j = 1:length(routes_included)
            for l = j+1:length(routes_included)
                streamID1 = routes_included(j);
                streamID2 = routes_included(l);
                
                % Write the loop structure for repetitions
                fprintf(outputFile, 'forall(k in 0..%d-1) {\n',k_max);
                % Write the loop structure for repetitions
                fprintf(outputFile, 'forall(alpha in 0..repetitions[%d]-1, beta in 0..repetitions[%d]-1) {\n', streamID1, streamID2);
            
                % Write the first condition
                constraint1 = sprintf('OFF_%d_%s - OFF_%d_%s <= (alpha*T_period[%d] - beta*T_period[%d]) - ceil(trans_delay[%d] + 1) ||\n', ...
                    streamID2, switchID, streamID1, switchID, streamID1, streamID2, streamID2);
                fprintf(outputFile, '%s', constraint1);
            
                % Write the second condition
                constraint2 = sprintf('OFF_%d_%s - OFF_%d_%s <= (beta*T_period[%d] - alpha*T_period[%d]) - ceil(trans_delay[%d] + 1);\n', ...
                    streamID1, switchID, streamID2, switchID, streamID2, streamID1, streamID1);
                fprintf(outputFile, '%s', constraint2);
            
                % Close the loop structure
                fprintf(outputFile, '}}\n\n');

            end
        end
    end
end

%% The frame arrival constraint

% Sort the rows by the first column (switch names)
[~, idx] = sort(switchToStreams(:, 1));  % Sorting based on the first column (switch names)
sorted_switchToStreams = switchToStreams(idx, :);

fprintf(outputFile, '\n%s\n', '// The frame arrival constraint');

for i = 1:size(sorted_switchToStreams, 1)
    switchID = sorted_switchToStreams{i, 1}; %Load the current switch in question
    streamList = sorted_switchToStreams{i, 2}; %Load the stream IDs associated
    
    fprintf(outputFile, '\n// Switch %d', i);
    if gt(length(streamList),1) %Only proceed if the switch has more than 1 stream
        for j = 1:length(streamList)
            for k = j+1:length(streamList)
                streamID1 = streamList(j); %Extract the stream ID for the first stream
                streamID2 = streamList(k); %Extract the stream ID for the second stream

                % Find the previous devices for these streams from the
                % function
                prevDevice1 = findPreviousDevice(routes{streamID1}, switchID);
                prevDevice2 = findPreviousDevice(routes{streamID2}, switchID);
                
                % Write the loop structure for repetitions
                fprintf(outputFile, '\nforall(alpha in 0..repetitions[%d]-1, beta in 0..repetitions[%d]-1) {\n', streamID1, streamID2);

                % Write the first condition
                constraint1 = sprintf('OFF_%d_%s + alpha*T_period[%d] <= OFF_%d_%s + beta*T_period[%d] + (L[%d] - delta)||\n',...
                    streamID1, switchID, streamID1, streamID2, prevDevice2, streamID2, streamID2);
                fprintf(outputFile, '%s', constraint1);
                
                % Write the second condition
                constraint2 = sprintf('OFF_%d_%s + beta*T_period[%d] <= OFF_%d_%s + alpha*T_period[%d] + (L[%d] - delta);\n',...
                    streamID2, switchID, streamID2, streamID1, prevDevice1, streamID1, streamID1);
                fprintf(outputFile, '%s', constraint2);
                
                % Close the loop structure
                fprintf(outputFile, '}\n');
            end
        end
    end

end

%% The e2e latency: lamda = last_offset.OFF + trans_delay(switch_ID) - first_offset.OFF

fprintf(outputFile, '\n\n // The e2e latency: lamda = last_offset.OFF + trans_delay(switch_ID) - first_offset.OFF');

% Loop through each stream/route
for i = 1:length(routes)
    devices = strsplit(routes{i}, ',');

    % Identiy the source
    sources = devices(startsWith(devices, 'source'));

    % Identify switches in the route
    switches = devices(startsWith(devices, 'switch'));

    e2e_constraint_1 = sprintf('lambda_%d == OFF_%d_%s  - OFF_%d_%s + (trans_delay[%d] + prop_delay);',i,i,switches{length(switches)},i,sources{1},i);

    fprintf(outputFile, '\n%s', e2e_constraint_1);
end

%% The e2e latency boundaries

fprintf(outputFile, '\n\n%s', '// The e2e latency boundaries');

% Loop through each stream/route
for i = 1:length(routes)
    devices = strsplit(routes{i}, ',');

    e2e_constraint_2 = sprintf('min_e2e[%d] <= lambda_%d <= deadline[%d];',i,i,i);

    fprintf(outputFile, '\n%s', e2e_constraint_2);
end

%% Closing 
fprintf(outputFile, '\n}');

% Close the file
fclose(outputFile);

% Display notification
disp('Output file "output_CPLEX_code_generator_WCD.mod" has been generated in the CPLEX_Code_Output folder.');


%% Find the previous device in the route

function prevDevice = findPreviousDevice(route, currentSwitch)
    devices = strsplit(route, ',');
    currentIndex = find(strcmp(devices, currentSwitch));
    if currentIndex > 1
        prevDevice = devices{currentIndex - 1};
    else
        prevDevice = error('!!! Previous device does not exist, incorrect implementation !!!'); 
    end
end

