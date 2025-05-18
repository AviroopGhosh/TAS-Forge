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

# 🪜Step-by-Step Guide: Generating Schedules with NCA and WCA Methods Using TAS-Forge
This showcase follows the step-by-step walkthrough as detailed in the [User Guide](../../documentation/User_Guide.md).

For an understanding of the different scheduling frameworks, read the [Technical Overview](../../documentation/Technical_Overview.md). 

## 🚧 Step 1: Configure the Network Topology 
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
source2 ---> sink1
source1 ---> sink2
source1 ---> sink3
source5 ---> sink4
source3 ---> sink5
source4 ---> sink3
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

## 🦸 Step 2: Workflow for NCA Scheduling Framework 
After generating the network topology, the workflows for each scheduling framework should be separated. This step outlines the complete process for the NCA scheduling framework—from schedule generation and GCL creation to OMNeT++ simulation and result analysis.

### 🧍‍♂Step 2A: Solve NCA TAS Schedules using IBM CPLEX
- From the `CPLEX_Code_Output` folder select the `output_CPLEX_code_generator_NCA.mod` file. 
- Launch CPLEX Optimization Study, and after creating an OLP project, run the `.mod` file.
- Once executed, the **decison variables** (similar as shown) outputs are generated in the **Solutions** tab in CPLEX studio.
<pre>
lambda_1 = 96.57;
lambda_2 = 124.57;
lambda_3 = 152.07;
lambda_4 = 151.32;
lambda_5 = 152.32;
lambda_6 = 180.32;
OFF_1_source5 = 66;
OFF_1_switch2 = 88;
OFF_1_switch3 = 112;
OFF_1_switch4 = 141;
OFF_2_source2 = 74;
OFF_2_switch1 = 81;
OFF_2_switch2 = 114;
OFF_2_switch3 = 138;
OFF_2_switch4 = 167;
OFF_3_source1 = 0;
OFF_3_switch1 = 17;
OFF_3_switch2 = 50;
OFF_3_switch3 = 74;
OFF_3_switch4 = 103;
OFF_3_switch5 = 133;
OFF_4_source3 = 114;
OFF_4_switch1 = 119;
OFF_4_switch2 = 152;
OFF_4_switch3 = 176;
OFF_4_switch4 = 205;
OFF_4_switch5 = 235;
OFF_5_source4 = 0;
OFF_5_switch2 = 22;
OFF_5_switch3 = 46;
OFF_5_switch4 = 75;
OFF_5_switch5 = 105;
OFF_5_switch6 = 137;
OFF_6_source1 = 1141;
OFF_6_switch1 = 1158;
OFF_6_switch2 = 1191;
OFF_6_switch3 = 1215;
OFF_6_switch4 = 1244;
OFF_6_switch5 = 1274;
OFF_6_switch6 = 1306;
</pre>
- The CPLEX directory should generate the `output_CPLEX_solution_NCA.txt` file containing all the relevant decision variables. 

## 🦹
