%% function_read_topology_data.m
% Description: This function reads a csv file and returns the data as a
% string array
% Dependencies: port_connections.csv

function portconnections = function_read_topology_data(filename, dataLines)

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Source", "SourcePort", "Destination", "DestinationPort", "RoutesIncluded"];
opts.VariableTypes = ["string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Source", "SourcePort", "Destination", "DestinationPort", "RoutesIncluded"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Source", "SourcePort", "Destination", "DestinationPort", "RoutesIncluded"], "EmptyFieldRule", "auto");

% Import the data
portconnections = readmatrix(filename, opts);

end