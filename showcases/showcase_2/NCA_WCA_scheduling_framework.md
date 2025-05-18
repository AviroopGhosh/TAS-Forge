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

## 🚧 Step 1: Configure the Network Topology 
- Open MATLAB and navigate to the TAS-Forge project folder.
- Run the following script:
  <pre>
  generate_network_system  
  </pre>
- Enter the number of 🔺 **5 sources**, 🟢 **5 sinks** & 🟦 **6 switches** in the input text box.
- 
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
