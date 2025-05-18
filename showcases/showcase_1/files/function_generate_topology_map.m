%% function_generate_topology_map.m
% Description: Generate the network topology map
% Dependencies: Run generate_network_system.m, function_generate_routes.m
% Outputs: port_connections.csv

function output = function_generate_topology_map(G, routes)

    % Load the end node connections
    endNodes = G.Edges.EndNodes;

    % Initialize containers to track ports
    portMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % Initialize a cell array to store connection information
    connections = {};

    % Iterate over each pair of nodes in endNodes
    for i = 1:size(endNodes, 1)
        src = endNodes{i, 1};
        dst = endNodes{i, 2};

        % Assign a port to the source node if not already assigned
        if ~isKey(portMap, src)
            portMap(src) = 0;
        end

        % Assign a port to the destination node if not already assigned
        if ~isKey(portMap, dst)
            portMap(dst) = 0;
        end

        % Record the current port for both source and destination
        srcPort = portMap(src);
        dstPort = portMap(dst);

        % Store the connection information
        connections{end + 1, 1} = src;
        connections{end, 2} = srcPort;
        connections{end, 3} = dst;
        connections{end, 4} = dstPort;

        % Increment the port numbers for the next connection
        portMap(src) = portMap(src) + 1;
        portMap(dst) = portMap(dst) + 1;
    end

    % Initialize a cell array to store route indices
    routesIncluded = cell(size(connections, 1), 1);

    % Iterate over connections to find corresponding routes
    for i = 1:size(connections, 1)
        matchedRoutes = [];
        for j = 1:length(routes)
            route_devices = string(routes{j});
            check1 = sum(ismember(route_devices, connections{i,1})); % Compare the source port
            check2 = sum(ismember(route_devices, connections{i,3})); % Compare the destination port
            if ge(check1,1) && ge(check2,1)  % If both source and destination pairs are in the route
                matchedRoutes = [matchedRoutes, j];  % Store the route index
            end
        end
        % Convert matchedRoutes to a string and store in routesIncluded
        if isempty(matchedRoutes)
            routesIncluded{i} = '0';
        else
            routesIncluded{i} = strjoin(string(matchedRoutes), ', ');
        end
    end

    % Convert the connections cell array to a table
    connectionsTable = cell2table(connections, 'VariableNames', {'Source', 'SourcePort', 'Destination', 'DestinationPort'});

    % Add the routesIncluded as a new column in the connectionsTable
    connectionsTable.RoutesIncluded = routesIncluded;

    % Write the table to a CSV file
    writetable(connectionsTable, 'port_connections.csv');
    
    %Note:  The output csv is generated as a csv
    output = 1;
end
