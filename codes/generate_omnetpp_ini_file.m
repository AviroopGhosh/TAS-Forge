%% generate_omnetpp_ini_file.m
% Description: This script generates the ini file 
% Dependencies: run generate_omnetpp_files
% Output: generated_topology_'TAS_Schedule_Framework'.ned

% Do not proceed if the source offset values have not been loaded
if isempty(source_offsets_matrix)
    error('!!! Source offset values not available !!!')
end

% Do not proceed if switch gate states are not loaded
if isempty(gate_state_array)
    error('!!! Gate states not loaded !!!')
end

% Gather a list of nodes
listNodes = G.Nodes;

% Define the file name
dirName         = OMNETppDir;
outputFileName  = strcat('simulation_config_',scheduler_input,'.ini');
allFileName     = strcat(dirName,'/',outputFileName);

% Open the file for writing
fileID = fopen(allFileName, 'w');

% Load the stream_data.csv file with original column names
streamData = readtable('stream_data.csv', 'VariableNamingRule', 'preserve');

% Load the network_data.csv file with original column names
networkData = readtable('network_data.csv','VariableNamingRule','preserve');

% Load the node_data.csv file with the original column names
nodeData = readtable('node_data.csv','VariableNamingRule','preserve');

%% Generate the start of file 

% Write the General section
fprintf(fileID, '[General]\n');
fprintf(fileID, 'network = TS_network\n');
% Uncomment the next line if you require OMNeT++ 6.0
% fprintf(fileID, '#abstract-config = true (requires omnet 6)\n');
fprintf(fileID, '\n# Simulation setup and time\n');
fprintf(fileID, 'sim-time-limit = 1s\n\n');

% Write the Ethernet configuration section
fprintf(fileID, '# Ethernet\n');
fprintf(fileID, '*.*.ethernet.typename 	= "EthernetLayer"\n');
fprintf(fileID, '*.*.eth[*].typename 	= "LayeredEthernetInterface"\n');
fprintf(fileID, '*.*.eth[*].bitrate 		= 1 Gbps\n\n');

% Write the IPv4 network configurator section
fprintf(fileID, '# IPv4 network configurator with ARP\n');
fprintf(fileID, '**.configurator.dumpAddresses = true\n');
fprintf(fileID, '**.configurator.dumpTopology = true\n');
fprintf(fileID, '**.configurator.dumpLinks = true\n');
fprintf(fileID, '**.configurator.dumpRoutes = true\n');
fprintf(fileID, '**.configurator.arp.typename = "GlobalArp"\n\n');

% Write the routing table and configurator settings
fprintf(fileID, '*.*.ipv4.routingTable.netmaskRoutes = ""\n\n');

% Write the XML-based configurator settings with correct escaping
fprintf(fileID, '*.configurator.config = xml("<config> \\\n');
fprintf(fileID, '    <interface hosts=\''**\'' address=\''10.0.0.x\'' netmask=\''255.255.255.0\''/> \\\n');
fprintf(fileID, '</config>")\n\n');

fprintf(fileID, '**.configurator.interfaces = "eth[*]"\n\n');

% Write the IP interface visualizer section
fprintf(fileID, '# IP interface visualizer\n');
fprintf(fileID, '*.visualizer.interfaceTableVisualizer.displayInterfaceTables = true\n');

%% Generate the UDP source applications

noStreams = length(routes);
sourceSinkPairs = cell(0);
sourceList = cell(0);
sinkList = cell(0);
appIndex_src = zeros; %App index for sources
appIndex_sink = zeros; %App index for sinks

% Calculate the number of Apps for each source
for i = 1:noStreams
    % Split the route string into components
    pathComponents = strsplit(routes{i}, ',');
    
    % The first component is the source
    source = pathComponents{1}; 
    
    % The last component is the sink
    sink = pathComponents{end};
    
    % Store the source and sink
    sourceSinkPairs{i, 1} = source;
    sourceSinkPairs{i, 2} = sink;
    sourceList{i} = source;
    sinkList{i} = sink;
    
    % Calculate the app index for each source and sink
    appIndex_src(i) = sum(strcmp(sourceList, source)) - 1;
    appIndex_sink(i) = sum(strcmp(sinkList, sink)) - 1;
end

fprintf(fileID, '# Application description: source applications\n');
sourceListuniq = unique(sourceList); %Generate a unique set of sources

for i = 1:length(sourceListuniq)
    fprintf(fileID, "*.%s.numApps = %d\n",sourceListuniq{i},sum(strcmp(sourceList,sourceListuniq{i})));
end

fprintf(fileID, '\n*.source*.app[*].typename = "UdpSourceApp"\n\n');

% Preserve the stream ID, source and sink in ini file to match later
ini_stream_src_sink_data = {}; 

% Generate UDP apps for streams
for i = 1:noStreams
    streamID = i; 
    source  = sourceSinkPairs{i,1};
    sink    = sourceSinkPairs{i,2};

    fprintf(fileID, '# Stream %d: %s ---> %s\n', streamID, source, sink);
    fprintf(fileID, '*.%s.app[%d].typename = "UdpSourceApp"\n', source, appIndex_src(i));
    fprintf(fileID, '*.%s.app[%d].display-name = "iso%d"\n', source, appIndex_src(i), streamID);
    fprintf(fileID, '*.%s.app[%d].io.destAddress = "%s"\n', source, appIndex_src(i), sink);
    fprintf(fileID, '*.%s.app[%d].io.destPort = 1%d0\n', source, appIndex_src(i), streamID);
    fprintf(fileID, '*.%s.app[%d].source.packetLength = %dB\n',...
        source, appIndex_src(i),streamData.('Payload Bytes')(streamID));
    fprintf(fileID, '*.%s.app[%d].source.productionInterval = %dus\n', ...
        source, appIndex_src(i), streamData.('Periodicity')(streamID)*(networkData.('Macrotick')/1e-6)); %Convert from mts to us
    fprintf(fileID, '*.%s.app[%d].source.packetNameFormat = "iso%d-%%c"\n\n', source, appIndex_src(i), streamID);
    
    ini_stream_src_sink_data(i,:) = {streamID, source, sink};
end



%% Define the source queue 

fprintf(fileID, '# Define the source queues \n');
fprintf(fileID, '*.source*.eth[*].macLayer.queue.typename = "DropTailQueue"\n');
fprintf(fileID, '*.source*.eth[*].macLayer.queue.packetCapacity = 300\n');
fprintf(fileID, '*.source*.eth[*].macLayer.queue.dataCapacity = 363360b\n');

%% Define the stream identifiers

fprintf(fileID, '\n# Define the stream identifiers \n');
fprintf(fileID, '**.source*.hasOutgoingStreams = true\n');

for i = 1:length(sourceListuniq)
    fprintf(fileID, '**.%s.bridging.streamIdentifier.identifier.mapping = [', sourceListuniq{i});
    stream_inst = 0; % Count instances the streams appear in switch
    for j = 1:noStreams
        if strcmp(sourceList{j},sourceListuniq{i})
            stream_inst = stream_inst + 1;
        end
    end

    counter = 0;
    for j = 1:noStreams
        % Compare current source to match stream instances
        if strcmp(sourceList{j},sourceListuniq{i})
            counter = counter + 1;
            if lt(counter,stream_inst)
                % Add a comma if there are more stream instances
                fprintf(fileID, '{stream: "iso%d", packetFilter: expr(has(udp) && udp != nullptr && udp.destPort == 1%d0)},',j,j);
            else
                % Do not add comma if no further stream instances
                fprintf(fileID, '{stream: "iso%d", packetFilter: expr(has(udp) && udp != nullptr && udp.destPort == 1%d0)}',j,j);
            end
        end
    end
    fprintf(fileID, ']\n');
end

%% Define the sink UDP applications 

fprintf(fileID, '\n# Define the sink applications \n');

sinkListvar = unique(sinkList); %Generate a unique set of sources

% List the number of applications of sink
for i = 1:length(sinkListvar)
    fprintf(fileID, "**.%s.numApps = %d\n",sinkListvar{i},sum(strcmp(sinkList,sinkListvar{i})));
end

fprintf(fileID, '\n**.sink*.app[*].typename = "UdpSinkApp"\n');

% List the port ids of sinks corresponding to streams
for i = 1:noStreams
    streamID = i;
    fprintf(fileID, "**.%s.app[%d].io.localPort = 1%d0\n",sinkList{i},appIndex_sink(i),streamID);
end

%% Define the processing delays
proc_delay = networkData.("Processing Delay");
mt = networkData.("Macrotick");

fprintf(fileID, "\n# List the processing delays for the nodes\n");
fprintf(fileID, "*.GM*.ethernet.delayer.delay 	= 0us\n");
fprintf(fileID, "*.source*.ethernet.delayer.delay 	= 0us\n");
fprintf(fileID, "*.sink*.ethernet.delayer.delay 	= 0us\n");
fprintf(fileID, "*.switch*.ethernet.delayer.delay 	= %gus\n",(proc_delay*mt/1e-6));

%% Time Aware Shaper Initialization

fprintf(fileID, '\n# Time Aware Shaper Initialization \n');
fprintf(fileID,'\n*.switch*.hasEgressTrafficShaping = true\n');
fprintf(fileID, '\n*.switch*.eth[*].macLayer.queue.numTrafficClasses = 2\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.queue[0].display-name = "iso"\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.queue[1].display-name = "Gptp"\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.typename = "GatingPriorityQueue"\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.numQueues = 2\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.classifier.typename = "ContentBasedClassifier"\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.classifier.packetFilters = ["iso*", "Gptp*"]\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.scheduler.typename = "PriorityScheduler"\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.queue[*].typename = "DropTailQueue"\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.**.queue[*].packetCapacity = 300\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.**.queue[*].dataCapacity = 363360b\n');

%% Define the source offsets

mt = networkData.('Macrotick'); %Gather the macrotick value

fprintf(fileID, '\n# Specify the offsets for the sources \n');

topologyData = function_read_topology_data('port_connections.csv', 2); %Read the topology connections
src_counter = 0; %The source counter

for i = 1:length(topologyData)
    routes_included = str2double(strsplit(topologyData(i,5))); % List of routes
    if startsWith(topologyData(i,1),'source')
        src_counter = src_counter + 1; % Increment number of sources found
        sourceID = topologyData(i,1); % Locate the source ID
        src_offsets = source_offsets_matrix{src_counter}; 
        for k = 1:length(routes_included)
            var = src_offsets(k)*mt/1e-6; %Convert to us from mts
            fprintf(fileID, '\n*.%s.app[%d].source.initialProductionOffset = %gus', sourceID, k-1, var);
            fprintf(fileID, ' # Source %d', routes_included(k));
        end
    end
end

%% Specify the Gate States

fprintf(fileID, '\n\n# The initial gate states for switches and corresponding egress ports \n');

sw_port_counter = 0; %The switch and egress port counter

for i = 1:length(topologyData)
    routes_included = str2double(strsplit(topologyData(i,5)));
    if startsWith(topologyData(i,1),'switch') && ge(length(routes_included),1)
        sw_port_counter = sw_port_counter + 1; %Increment the counter
        sw_id = topologyData(i,1); %Gather the switch ID
        src_port = topologyData(i,2); %The corresponding egress port
        if eq(gate_state_array{sw_port_counter},0) %If initially open is False
            fprintf(fileID, '\n# Gate state for %s port %s\n', sw_id,src_port);
            fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[0].initiallyOpen = false\n', sw_id, src_port);
            fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[1].initiallyOpen = true\n', sw_id, src_port);
            fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[2].initiallyOpen = true\n', sw_id, src_port);
        else
            fprintf(fileID, '# Gate state for %s port %s\n', sw_id,src_port);
            fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[0].initiallyOpen = true\n', sw_id, src_port);
            fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[1].initiallyOpen = false\n', sw_id, src_port);
            fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[2].initiallyOpen = false\n', sw_id, src_port);
        end
    end
end

%% Formulate the GCLs
GCLfileID = 'output_GCL_matrix.txt';

GCL_list = function_read_text_file(GCLfileID);
GCL_counter = 0;

fprintf(fileID, '\n\n# Formulate the Gate Control Lists in the network \n');

for i = 1:length(topologyData)
    routes_included = str2double(strsplit(topologyData(i,5)));
    if startsWith(topologyData(i,1),'switch') && ge(length(routes_included),1)
        GCL_counter = GCL_counter + 1;
        sw_id = topologyData(i,1);
        src_port = topologyData(i,2);
        fprintf(fileID, '\n# GCL of %s Egress port %s\n',sw_id,src_port);
        fprintf(fileID, '*.%s.eth[%s].macLayer.queue.gate[*].durations = %s\n',sw_id,src_port,string(GCL_list(GCL_counter)));
    end
end

%% Enable gPTP and GM initialization

fprintf(fileID, '\n# Enable time synchronization');
fprintf(fileID, '\n*.*.hasTimeSynchronization = true');
fprintf(fileID, '\n**.oscillator.typename = "ConstantDriftOscillator"');

fprintf(fileID, '\n\n# Enable oscillators in the GM');

for i = 1:length(topologyData)
    if startsWith(topologyData(i,1),'GM')
        GM_identifier = topologyData(i,1);
        fprintf(fileID, '\n*.%s*.app[*].source.clockModule = "^.^.clock"\n', GM_identifier);
    end
end

fprintf(fileID, '\n# Clock configuration for GM');
for i = 1:length(topologyData)
    if startsWith(topologyData(i,1),'GM')
        GM_identifier = topologyData(i,1);
        fprintf(fileID, '\n*.%s.clock.typename = "SettableClock"', GM_identifier);
        fprintf(fileID, '\n*.%s.gptp.typename = "MultiDomainGptp"', GM_identifier);
        fprintf(fileID, '\n*.%s.gptp.numDomains = 1', GM_identifier);
    end
end

fprintf(fileID, '\n\n# gPTP configuration for the GM\n');
for i = 1:length(topologyData)
    if startsWith(topologyData(i,1),'GM')
        GM_identifier = topologyData(i,1); %Identify the GM
        fprintf(fileID, '\n*.%s.gptp.domain[*].clockModule = "%s.clock"', GM_identifier,GM_identifier);
        fprintf(fileID, '\n*.%s.gptp.domain[0].gptpNodeType = "MASTER_NODE"', GM_identifier);
        fprintf(fileID, '\n*.%s.gptp.domain[0].masterPorts = ["eth0"]\n', GM_identifier);
    end
end

%% gPTP Configuration in sources

% Oscillators in source
fprintf(fileID, '\n# Enable oscillators in the sources');
fprintf(fileID, '\n*.source*.app[*].source.clockModule = "^.^.clock"\n');

% Clock configuration 
fprintf(fileID, '\n# Clock configuration for sources');
fprintf(fileID, '\n*.source*.clock.typename = "SettableClock"');
fprintf(fileID, '\n*.source*.gptp.typename = "MultiDomainGptp"');
fprintf(fileID, '\n*.source*.gptp.numDomains = 1');

% gPTP configuration
fprintf(fileID, '\n\n# Enable gptp configuration for sources\n');
for i = 1:length(topologyData)
    if startsWith(topologyData(i,1),'source')
        src_identifier = topologyData(i,1);
        src_port = str2double(topologyData(i,2));
        fprintf(fileID, '\n*.%s.gptp.domain[*].clockModule = "%s.clock"',src_identifier,src_identifier);
        fprintf(fileID, '\n*.%s.gptp.domain[0].gptpNodeType = "SLAVE_NODE"', src_identifier);
        fprintf(fileID, '\n*.%s.gptp.domain[0].slavePort = "eth%d"\n',src_identifier,src_port);
    end
end

%% gPTP Configuration in switches

% Enable oscillators in the switches
fprintf(fileID, '\n# Enable oscillators in the switches\n');
fprintf(fileID, '*.switch*.eth[*].macLayer.queue.gate[*].clockModule = "^.^.^.^.clock"\n');

% Clock configuration for switches
fprintf(fileID, '\n# Clock configuration for switches\n');
fprintf(fileID, '*.switch*.hasGptp = true\n');
fprintf(fileID, '*.switch*.clock.typename = "MultiClock"\n');
fprintf(fileID, '*.switch*.clock.numClocks = 1\n');
fprintf(fileID, '*.switch*.gptp.typename = "MultiDomainGptp"\n');
fprintf(fileID, '*.switch*.gptp.numDomains = 1\n');

% gPTP configuration for switches
fprintf(fileID, '\n# gPTP configuration for switches\n');

% Find the Grandmaster (GM) device and connected switch
gm_device = '';
gm_con_sw = '';

for i = 1:length(topologyData)
    if startsWith(topologyData{i, 1}, 'GM')
        gm_device = topologyData{i, 1};
        gm_con_sw = topologyData{i,3};
        break;
    end
end

gm_con_sw_id = str2double(regexp(gm_con_sw, '\d+', 'match')); % Connected switch id

for i = 1:size(listNodes,1)
    
    current_device = string(listNodes{i,:}); 

    % Check if current device is a switch
    if startsWith(current_device, 'switch')

        sw_id = str2double(regexp(current_device, '\d+', 'match')); % Current switch ID
        slavePort = []; % Initialize slave port
        masterPorts = []; % Initialize the master ports

        for j = 1:length(topologyData)
            % If connected devices are sources, then connected ports are
            % master ports 
            if strcmp(topologyData{j,3}, current_device) && startsWith(topologyData{j, 1}, 'source')
                dst_port = str2double(topologyData{j, 4});
                masterPorts = [masterPorts, dst_port];
            end
            % If connected devices are sinks, then connected ports are
            % master ports
            if strcmp(topologyData{j,1}, current_device) && startsWith(topologyData{j, 3}, 'sink')
                src_port = str2double(topologyData{j, 2});
                masterPorts = [masterPorts, src_port];
            end
            % If switch port id is less than gm port id
            if lt(sw_id, gm_con_sw_id)
                % Connected port to switch with greater id will be slave port 
                if strcmp(topologyData{j,1}, current_device) && startsWith(topologyData{j, 3}, 'switch')
                    src_port = str2double(topologyData{j, 2});
                    slavePort = src_port;
                end
                % Other connected switches will be master ports
                if strcmp(topologyData{j,3}, current_device) && startsWith(topologyData{j, 1}, 'switch')
                    dst_port = str2double(topologyData{j, 4});
                    masterPorts = [masterPorts, dst_port];
                end
            end
            % If switch port id is greater than gm port id
            if gt(sw_id, gm_con_sw_id)
                % Connected port to switch with lesser id will be slave port 
                if strcmp(topologyData{j,1}, current_device) && startsWith(topologyData{j, 3}, 'switch')
                    src_port = str2double(topologyData{j, 2});
                    masterPorts = [masterPorts, src_port];                    
                end
                % Other connected switches will be master ports
                if strcmp(topologyData{j,3}, current_device) && startsWith(topologyData{j, 1}, 'switch')
                    dst_port = str2double(topologyData{j, 4});
                    slavePort = dst_port;
                end
            end
            % If the current switch is the GM
            if eq(sw_id, gm_con_sw_id)
                % Port switches connected to the GM
                if strcmp(topologyData{j,3}, current_device) && startsWith(topologyData{j, 1}, 'GM')
                    dst_port = str2double(topologyData{j, 4});
                    slavePort = dst_port;
                end
                % Any switches will be connected to master ports
                if strcmp(topologyData{j,1}, current_device) && startsWith(topologyData{j, 3}, 'switch')
                    src_port = str2double(topologyData{j, 2});
                    masterPorts = [masterPorts, src_port];                    
                end
                if strcmp(topologyData{j,3}, current_device) && startsWith(topologyData{j, 1}, 'switch')
                    dst_port = str2double(topologyData{j, 4});
                    masterPorts = [masterPorts, dst_port];
                end
            end
        end
        fprintf(fileID, '*.%s.gptp.domain[0].slavePort = "eth%d"\n', current_device, slavePort);
        fprintf(fileID, '*.%s.gptp.domain[0].masterPorts = [', current_device);
        for j = 1:length(masterPorts)
            if j > 1
                fprintf(fileID, ', ');
            end
            fprintf(fileID, '"eth%d"', masterPorts(j));
        end
        fprintf(fileID, ']\n');
    end
end

%% gPTP Configuration for sinks

% gPTP configuration for sinks
fprintf(fileID, '\n# gPTP configuration for sinks\n');
fprintf(fileID, '*.sink*.clock.typename = "MultiClock"\n');
fprintf(fileID, '*.sink*.clock.numClocks = 1\n');
fprintf(fileID, '*.sink*.gptp.typename = "MultiDomainGptp"\n');
fprintf(fileID, '*.sink*.gptp.numDomains = 1\n');

for i = 1:size(listNodes,1)    
    current_device = string(listNodes{i,:});   
    for j = 1:length(topologyData)
        if startsWith(current_device, 'sink')
            dst_port = str2double(topologyData{j,4});
            fprintf(fileID, '*.%s.gptp.clockModule = "%s.clock"\n', current_device, current_device);
            fprintf(fileID, '*.%s.gptp.domain[0].slavePort = "eth%d"\n', current_device, dst_port);
            break;
        end
    end
end

%% Load the clock drift information of all devices

listNodes = string(nodeData.('Node_Name'));
clockDrift = nodeData.('Clock_Drift');

% Clock drift of the GM
fprintf(fileID, '\n# Clock drift of the GM\n');
for i = 1:length(listNodes)
    if startsWith(listNodes(i),'GM')
        fprintf(fileID, '*.%s.clock.oscillator.driftRate = %g ppm\n',listNodes(i),clockDrift(i)/1e-6);
        break
    end
end

% Clock drift of the sources
fprintf(fileID, '\n# Clock drift of the sources\n');
for i = 1:length(listNodes)
    if startsWith(listNodes(i),'source')
        fprintf(fileID, '*.%s.clock.oscillator.driftRate = %g ppm\n',listNodes(i),clockDrift(i)/1e-6);
    end
end

% Clock drift of the switches
fprintf(fileID, '\n# Clock drift of the switches\n');
for i = 1:length(listNodes)
    if startsWith(listNodes(i),'switch')
        fprintf(fileID, '*.%s.clock.*.oscillator.driftRate = %g ppm\n',listNodes(i),clockDrift(i)/1e-6);
    end
end

% % Clock drift of the sinks
% fprintf(fileID, '\n# Clock drift of the sinks\n');
% for i = 1:length(listNodes)
%     if startsWith(listNodes(i),'sink')
%         fprintf(fileID, '*.%s.clock.oscillator.driftRate = %g ppm\n',listNodes(i),clockDrift(i)/1e-6);
%     end
% end

%% gPTP synchronization parameters

mt = networkData.('Macrotick');
sync_period = networkData.('Sync Periodicity');

fprintf(fileID, '\n# gPTP synchronization parameters\n');
fprintf(fileID, '**.pdelayInitialOffset = 100 ns\n');
fprintf(fileID, '*.*.gptp.domain[0].syncInterval = %d ms\n', sync_period*mt*1e3);
fprintf(fileID, '*.*.gptp.domain[0].syncInitialOffset = syncInterval * 0.01\n');
fprintf(fileID, '*.*.gptp.*.syncError = 0 us\n');

fprintf(fileID, '\n# Set all reference clocks to master clock so the time difference can be visualized\n');
for i = 1:length(listNodes)
    if startsWith(listNodes(i),'GM')
        fprintf(fileID, '**.referenceClock = "%s.clock"\n',listNodes(i));
        break
    end
end

%% Closing of the scripts
% Close the file
fclose(fileID);

fprintf('INI file %s generated successfully in directory %s.\n', outputFileName, dirName);
