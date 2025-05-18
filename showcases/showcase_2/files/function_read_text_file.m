%% fuction_read_text_file.m
% Description: Reads text files and converts to a cell array

function file_output = function_read_text_file(input_file)
% Open the file for reading
fileID = fopen(input_file, 'r');

% Check if the file was opened successfully
if fileID == -1
    error('Failed to open the file. Check the file path.');
end

% Initialize a cell array to store the lines
lines = {};

% Read the file line by line
i = 1;
while ~feof(fileID)
    % Read a line from the file
    line = fgetl(fileID);
    
    % Store the line in the cell array
    lines{i} = line;
    i = i + 1;
end

% Close the file
fclose(fileID);

% Print message
fprintf('File "%s" read successfully\n',input_file);

file_output = lines;
end
