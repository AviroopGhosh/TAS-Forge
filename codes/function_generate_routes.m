%% function_generate_routes.m 
% Description: This function is used to generate pair of sources and sinks
% to form routes
% Dependencies: Run generate_network_system.m 

function routes = function_generate_routes(edgeTable)
    % Extract the start and end nodes from the table
    startNodes = edgeTable.EndNodes(:,1);  % Starting nodes
    adjNodes = edgeTable.EndNodes(:,2);    % Adjacent nodes

    % Filter and identify sources, sinks, and switches
    sources = unique(startNodes(startsWith(startNodes, 'source')));
    sinks = unique(adjNodes(startsWith(adjNodes, 'sink')));

    % Initialize pairing data structures
    numSources = numel(sources);
    numSinks = numel(sinks);

    % Error check to ensure at least one source or sink is available
    if numSources < 1 || numSinks < 1
        error('!!! Insufficient sources or sinks to form pairs. !!!');
    end

    % Create a directed graph from the edges to determine reachability
    G = digraph(startNodes, adjNodes);

    % Initialize source to sink pairings
    sourceSinkPairs = {};

    % Ensure that at least one source is connected to each sink
    for j = 1:numSinks
        sink = sinks{j};
        availableSources = {};  % Store sources that can reach this sink
        for i = 1:numSources
            source = sources{i};
            % Check if there is a path from source to sink
            if has_path(G, source, sink)
                availableSources{end + 1} = source;
            end
        end

        % If available sources found, pair the sink with one randomly
        if ~isempty(availableSources)
            sourceIdx = randi(length(availableSources));
            sourceSinkPairs{end + 1, 1} = availableSources{sourceIdx};
            sourceSinkPairs{end, 2} = sink;
        else
            fprintf('No upstream sources available for %s\n', sink);
        end
    end

    % Ensure all sources are paired by connecting unpaired sources
    pairedSources = sourceSinkPairs(:,1);
    unpairedSources = setdiff(sources, pairedSources);
    remainingSinks = sinks;

    % Pair remaining unpaired sources with available sinks
    for i = 1:numel(unpairedSources)
        source = unpairedSources{i};
        if ~isempty(remainingSinks)
            % Randomly pair with an available sink
            sinkIdx = randi(length(remainingSinks));
            sourceSinkPairs{end + 1, 1} = source;
            sourceSinkPairs{end, 2} = remainingSinks{sinkIdx};
            remainingSinks(sinkIdx) = [];  % Remove the paired sink from the list
        else
            % If no sinks are left, pair with any existing sink
            sinkIdx = randi(numel(sinks));
            sourceSinkPairs{end + 1, 1} = source;
            sourceSinkPairs{end, 2} = sinks{sinkIdx};
        end
    end
    
    % Print the pairs
    fprintf('\nSource to Sink Pairs:\n');
    for i = 1:size(sourceSinkPairs, 1)
        fprintf('%s ---> %s\n', sourceSinkPairs{i, 1}, sourceSinkPairs{i, 2});
    end

    % Return the pairs as output if needed elsewhere
    routes = sourceSinkPairs;
end

% Helper function to check if there is a path from source to sink
function pathExists = has_path(G, source, sink)
    try
        % Try to find the shortest path
        [~, pathExists] = shortestpath(G, source, sink);
        pathExists = ~isempty(pathExists);  % True if a path is found
    catch
        pathExists = false;  % If shortestpath fails, no path exists
    end
end
