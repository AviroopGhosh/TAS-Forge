%% generate_omnetpp_files.m
% Description: Generates both NED and INI files for OMNeT++ simulation 
% based on network topology and stream data.
% Dependencies: stream_data.csv, network_data.csv, node_data.csv,
% generate_GCL_output.m
% Outputs: OMNETpp_Code_Output Directory

OMNETppDir = 'OMNETpp_Code_Output'; % OMNETpp directory

if ~exist(OMNETppDir, 'dir')
    mkdir(OMNETppDir);
    fprintf(strcat(OMNETppDir,' directory has been created.\n'));
end

run("generate_omnetpp_ned_file.m");
run("generate_omnetpp_ini_file.m");