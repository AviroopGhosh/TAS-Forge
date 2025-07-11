# 🥅 Goal
This showcase provides a step-by-step walkthrough of TAS-Forge’s workflow for comparing two scheduling frameworks applied to the same network topology. It demonstrates the full TAS-Forge generation process using both the **Network-Derived Clock Drift Adjustment (NCA)** and **Worst-Case Adjustment (WCA)** scheduling methods.

The network topology considered consists of 🟦 **6 switches**, 🔺 **5 sources** and 🟢 **5 sinks**.  

The showcase highlights each major phase including:
- Generation of the network topology and time-sensitive streams.
- Formulation of TAS scheduling constraints using CPLEX for both the NCA and WCA scheduling methods.
- Generation of Gate Control Lists (GCLs) for the NCA method.
- Preparation and execution of simulation files for OMNeT++ for the NCA scheduling method.
- Generation of GCLs for the WCA method.
- Preparation and execution of simulation files for OMNeT++ for the WCA scheduling method.
- Analysis of the results from both scheduling frameworks.  

This guide demonstrates how to replicate the showcased example using TAS-Forge. 

🚨 **Do not** close MATLAB until all steps are completed. If you need to pause midway, use the save workspace command to preserve your progress, and resume later.

# 🪜Step-by-Step Guide: Generating Schedules with NCA and WCA Methods Using TAS-Forge
This showcase follows the step-by-step walkthrough as detailed in the [User Guide](../../documentation/User_Guide.md).

For an understanding of the different scheduling frameworks, read the [Technical Overview](../../documentation/Technical_Overview.md). 

## 🚥 Step 1: Configure the Network Topology 
- Open MATLAB and navigate to the TAS-Forge project folder.
- Run the following script:
  <pre>
  generate_network_system  
  </pre>
- Enter the number of 🔺 **5 sources**, 🟢 **5 sinks** & 🟦 **6 switches** in the input text box.
- A network topology will be automatically generated, similar to the one displayed as shown below:

![Network Topology](images/showcase_2_network_topology.png)

- The script also generates a set of **source-to-sink** for 6 routes:
<pre>
Source to Sink Pairs:
source5 ---> sink1
source2 ---> sink2
source1 ---> sink3
source2 ---> sink4
source4 ---> sink5
source3 ---> sink3
</pre>

- The `generate_network_system.m` script also generates `.csv` files containing information relevant to:
    - **Node clock drift information** (`node_data.csv`) for time synchronization modeling
    - **Network parameters** (`network_data.csv`) such as, link speeds, propagation delays, hyperperiod, etc.
    - **Stream definitions and properties** (`stream_data.csv`) such as, stream ids, routes, periodicity, payload size, deadlines
- Upon sucessful creation, the following messages will appear in the MATLAB command window.
<pre>
Node output file "node_data.csv" has been created.
Network output file "network_data.csv" has been created.
Stream output file "stream_data.csv" has been created.
Port connections output file "port_connections.csv" has been created.  
</pre> 
- The script also creates the `CPLEX_Code_Output` folder containing the `.mod` files for all supported scheduling frameworks. The MATLAB command window will display: 
<pre>
Directory created for storing CPLEX codes.
Output file "output_CPLEX_code_generator_WCD.mod" has been generated in the CPLEX_Code_Output folder.
Output file "output_CPLEX_code_generator_NCD.mod" has been generated in the CPLEX_Code_Output folder.
Output file "output_CPLEX_code_generator_WCA.mod" has been generated in the CPLEX_Code_Output folder.
Output file "output_CPLEX_code_generator_NCA.mod" has been generated in the CPLEX_Code_Output folder.  
</pre>

## 🙇 Step 2: Workflow for NCA Scheduling Framework 
After generating the network topology, the workflows for each scheduling framework should be separated. This step outlines the complete process for the NCA scheduling framework—from schedule generation and GCL creation to OMNeT++ simulation and result analysis.

### 🧍Step 2A: Solve NCA TAS Schedules using IBM CPLEX
- From the `CPLEX_Code_Output` folder select the `output_CPLEX_code_generator_NCA.mod` file. 
- Launch CPLEX Optimization Study, and after creating an OLP project, run the `.mod` file.
- Once executed, the **decison variables** (as shown) outputs are generated in the **Solutions** tab in CPLEX studio.
<pre>
lambda_1 = 97.07;
lambda_2 = 124.32;
lambda_3 = 125.07;
lambda_4 = 152.57;
lambda_5 = 153.32;
lambda_6 = 181.32;
OFF_1_source5 = 112;
OFF_1_switch2 = 139;
OFF_1_switch3 = 163;
OFF_1_switch4 = 195;
OFF_2_source2 = 61;
OFF_2_switch1 = 81;
OFF_2_switch2 = 109;
OFF_2_switch3 = 133;
OFF_2_switch4 = 165;
OFF_3_source4 = 169;
OFF_3_switch2 = 197;
OFF_3_switch3 = 221;
OFF_3_switch4 = 253;
OFF_3_switch5 = 270;
OFF_4_source2 = 31;
OFF_4_switch1 = 51;
OFF_4_switch2 = 79;
OFF_4_switch3 = 103;
OFF_4_switch4 = 135;
OFF_4_switch5 = 152;
OFF_5_source3 = 146;
OFF_5_switch2 = 163;
OFF_5_switch3 = 187;
OFF_5_switch4 = 219;
OFF_5_switch5 = 236;
OFF_5_switch6 = 264;
OFF_6_source1 = 0;
OFF_6_switch1 = 27;
OFF_6_switch2 = 55;
OFF_6_switch3 = 79;
OFF_6_switch4 = 111;
OFF_6_switch5 = 128;
OFF_6_switch6 = 156;
</pre>
- The CPLEX directory should generate the `output_CPLEX_solution_NCA.txt` file containing all the relevant decision variables required to be created for GCL generation. 
- Move the `output_CPLEX_solution_NCA.txt` file to the MATLAB directory where TAS-Forge is being executed.

### 🚶Step 2B: Create the GCLs
- To generate GCLs, run the following script to generate GCLs:
<pre>
generate_GCL_output  
</pre>

- Select the scheduler type when prompted. In this case, *NCA* needs to be entered.
- Note: If you entered another scheduler type, re-run the script. 
- The script will:
    - Create corresponding GCLs in the `output_GCL_matrix.txt`.
    - The **schedulability cost** metric is also displayed in the MATLAB command window.
<pre>
generate_GCL_output
What scheduler did you select (WCA/WCD/NCA/NCD)?:  NCA
File "output_GCL_matrix.txt" has been created.

The schedulability cost is 0.0636333
</pre>

### 🏃 Step 2C: Generate Simulation Configuration
- To generate the `.ned` and `.ini` files, run the following script:
<pre>
generate_omnetpp_files  
</pre>
- The script will create `OMNETpp_Code_Output` directory for storing the generated files.
- The `.ned` will be generated, along with a figure denoting all network devices and the traffic flow directions based on the topology (similar to the one shown below).
- If the `output_GCL_matrix.txt` file is read sucessfully, the script will also generate the corresponding `.ini` file containing the simulation configuration.
- Both files are necessary to run the TAS-Forge simulation inside OMNeT++.

![Network Topology NED](images/showcase_2_ned.png)

MATLAB command window output is shown below, displaying successful `.ned` and `.ini` file generation:
<pre>
generate_omnetpp_files
OMNETpp_Code_Output directory has been created.
NED file generated_topology.ned generated successfully in directory OMNETpp_Code_Output.
File "output_GCL_matrix.txt" read successfully
INI file simulation_config_NCA.ini generated successfully in directory OMNETpp_Code_Output.
</pre>

### 🤸 Step 2D: Analyzing Simulation Results
- Import the `.ned` and `.ini` generated from Step 2C and load into OMNeT++.
- Run the simulation for a default period of 1 second. 
- After the simulation completes, navigate to generated `.vec` result file.
- Filter the results based on selecting entries labeled `meanBitLifeTimePerPacket:vector`, representing the end-to-end latency.
- Export the results as a `.csv` file and name it `results.csv`.
- Transfer the `.csv` file to your MATLAB workspace with TAS-Forge.
- Run the following command in your MATLAB command window:
<pre>
 analyze_omnet_results 
</pre> 
- This should create a `stream_data_output_NCA.csv` file and the following prompt will be displayed:
<pre>
Warning: Table variable names were truncated to the length namelengthmax. The original names are saved in the
VariableDescriptions property. 
Results saved to stream_data_output_NCA.csv
Warning: Column headers from the file were modified to make them valid MATLAB identifiers before creating variable names
for the table. The original column headers are saved in the VariableDescriptions property.
Set 'VariableNamingRule' to 'preserve' to use the original column headers as table variable names. 
Results updated to stream_data_output_NCA.csv 
</pre>
- The warnings from MATLAB can be ignored.
- The output `.csv` file summaries the stream metrics including the analytical and meaured end-to-end latencies, jitter, routes, etc.
- The measured end-to-end latencies fall within the boundaries of the analytical end-to-end latencies.
- Since the schedule gurantees no queuing delays along the route, the minimum and maximum end-to-end latencies will be equal, resulting in zero jitter.

## 🙇‍♀️Step 3: Workflow for WCA Scheduling Framework
This step outlines the complete workflow for the WCA scheduling framework—from schedule generation and GCL creation to OMNeT++ simulation and result analysis.

### 🧍‍♀️Step 3A: Solve WCA TAS Schedules using IBM CPLEX
- From the `CPLEX_Code_Output` folder select the `output_CPLEX_code_generator_WCA.mod` file. 
- Launch CPLEX Optimization Study, and after creating an OLP project, run the `.mod` file.
- Once executed, the **decison variables** (as shown) outputs are generated in the **Solutions** tab in CPLEX studio.
<pre>
lambda_1 = 96.82;
lambda_2 = 124.82;
lambda_3 = 124.82;
lambda_4 = 152.82;
lambda_5 = 152.82;
lambda_6 = 180.82;
OFF_1_source5 = 284;
OFF_1_switch2 = 287;
OFF_1_switch3 = 315;
OFF_1_switch4 = 343;
OFF_2_source2 = 320;
OFF_2_switch1 = 323;
OFF_2_switch2 = 351;
OFF_2_switch3 = 379;
OFF_2_switch4 = 407;
OFF_3_source4 = 156;
OFF_3_switch2 = 159;
OFF_3_switch3 = 187;
OFF_3_switch4 = 215;
OFF_3_switch5 = 243;
OFF_4_source2 = 0;
OFF_4_switch1 = 3;
OFF_4_switch2 = 31;
OFF_4_switch3 = 59;
OFF_4_switch4 = 87;
OFF_4_switch5 = 115;
OFF_5_source3 = 220;
OFF_5_switch2 = 223;
OFF_5_switch3 = 251;
OFF_5_switch4 = 279;
OFF_5_switch5 = 307;
OFF_5_switch6 = 335;
OFF_6_source1 = 64;
OFF_6_switch1 = 67;
OFF_6_switch2 = 95;
OFF_6_switch3 = 123;
OFF_6_switch4 = 151;
OFF_6_switch5 = 179;
OFF_6_switch6 = 207;
</pre>
- The CPLEX directory should generate the `output_CPLEX_solution_WCA.txt` file containing all the relevant decision variables required to be created for GCL generation. 
- Move the `output_CPLEX_solution_WCA.txt` file to the MATLAB directory where TAS-Forge is being executed.

### 🚶‍♀️Step 3B: Create the GCLs
- To generate GCLs for the WCA scheduling method, run the following script to generate GCLs:
<pre>
generate_GCL_output  
</pre>

- **Note:** That will over-write the previously generated GCLs for the NCA scheduling method. 
- Select the scheduler type when prompted. In this case, *WCA* needs to be entered.
- The script will:
    - Create corresponding GCLs in the `output_GCL_matrix.txt`.
    - The **schedulability cost** metric is also displayed in the MATLAB command window.
<pre>
generate_GCL_output
What scheduler did you select (WCA/WCD/NCA/NCD)?:  WCA
File "output_GCL_matrix.txt" has been created.

The schedulability cost is 0.1408
</pre>

### 🏃‍♀️Step 3C: Generate Simulation Configuration
- To generate `.ini` file for the WCA scheduling method, run the following script:
<pre>
generate_omnetpp_files  
</pre>
- Since the `OMNETPP_Code_Output` directory was already created in Step 2C, it will not be recreated.
- The `.ned` will be re-generated, along with a topology diagram denoting all network devices and the traffic flow directions based on the topology.
- Given that this is the same `.ned` file generated from Step 2C, there is no need to copy it again into OMNeT++.
- The script will also generate the corresponding `.ini` file for the WCA scheduling method containing the simulation configuration.
- Load the `.ini` file in OMNeT++ to run the WCA configuration. 

MATLAB command window output is shown below, displaying successful `.ned` and `.ini` file generation:
<pre>
generate_omnetpp_files
NED file generated_topology.ned generated successfully in directory OMNETpp_Code_Output.
File "output_GCL_matrix.txt" read successfully
INI file simulation_config_WCA.ini generated successfully in directory OMNETpp_Code_Output.
</pre>

### 🤸‍♀️Step 3D: Analyzing Simulation Results
- Import the `.ini` generated from Step 3C and load into OMNeT++.
- Run the simulation for a default period of 1 second. 
- After the simulation completes, navigate to generated `.vec` result file.
- Filter the results based on selecting entries labeled `meanBitLifeTimePerPacket:vector`, representing the end-to-end latency.
- Export the results as a `.csv` file and name it `results.csv`.
- Transfer the `.csv` file to your MATLAB workspace with TAS-Forge.
- **Note:** This will overwrite any previous instances of `results.csv`. 
- Run the following command in your MATLAB command window:
<pre>
 analyze_omnet_results 
</pre> 
- This should create a `stream_data_outputWCA.csv` file, and you will see following prompt will be displayed:
<pre>
Warning: Table variable names were truncated to the length namelengthmax. The original names are saved in the
VariableDescriptions property. 
Results saved to stream_data_output_WCA.csv
Warning: Column headers from the file were modified to make them valid MATLAB identifiers before creating variable names
for the table. The original column headers are saved in the VariableDescriptions property.
Set 'VariableNamingRule' to 'preserve' to use the original column headers as table variable names. 
Results updated to stream_data_output_WCA.csv
</pre>
- The MATLAB warnings can be ignored safely. 
- The output `.csv` file summaries the stream metrics including the analytical and meaured end-to-end latencies, jitter, routes, etc.
- The measured end-to-end latencies fall within the boundaries of the analytical end-to-end latencies.
- Because the WCA schedule eliminates queuing delays, the minimum and maximum end-to-end latencies will be identical, resulting in zero jitter.

## 🏁 Step 4: Comparative Analysis
- To perform a comparative analysis between the NCA and WCA methods, examine the 'stream_data_output_NCA.csv' and 'stream_data_output_WCA.csv' files.
- Given the deterministic nature of both scheduling frameworks, the end-to-end latency and jitter values across all streams should be identical.
- However, a meaningful comparison can be made by analyzing the **schedulability cost**. This metric reflects the overall bandwidth efficiency of GCLs for each scheduling method.
- According to the MATLAB output, the schedulability cost is:
  - **0.063633** for the NCA framework.
  - **0.1408** for the WCA framework.
- These values indicate that the NCA method is approximately **54% more bandwidth efficient** than the WCA method.

## ✔️ Summary
This showcase demonstrated the complete TAS-Forge workflow for both the NCA and WCA scheduling methods using a common network topology. The process included:
- Generating the network topology and time-sensitive streams
- Scheduling creation using CPLEX for the NCA and WCA methods.
- GCL generation for both the scheduling methods.
- Running simulations in OMNeT++ and analyzing the results.

The outcomes of the WCA and NCA methods were compared using the output `.csv` files: `stream_data_output_NCA.csv` and `stream_data_output_WCA.csv`. 

While latency and jitter were identical due to the deterministic nature of the schedules, a meaningful distinction emerged through the **schedulability cost** metric. This metric captured the relative bandwidth efficiency of the overall network schedule, revealing that the NCA method is significantly more bandwidth-efficient than the WCA approach.

Similar workflows can be constructed to compare other scheduling frameworks such as NCD and WCD using the same network topology.
