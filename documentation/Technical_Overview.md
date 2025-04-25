# Technical Overview
TAS-Forge is a simulation and scheduling automation tool designed for Time-Sensitive Networking (TSN). It focuses on IEEE 802.1Qbv, the Time-Aware Shaper (TAS), while also incorporating IEEE 802.1AS time synchronization into the scheduling process. The tool automatically generates linear network topologies in MATLAB, formulates Gate Control Lists (GCLs) using Integer Linear Programming (ILP) via IBM CPLEX, and evaluates scheduling performance through simulations in OMNeT++.

🌟 **Important:** For an understanding of nomenclature used in this documentation such as `frames`,`streams`,`deadline`, etc. refer to [1] & [2]. 

## 🧩 System Architecture
TAS-Forge operates across five sequential phases:

1. Toplogy & Stream Generation (MATLAB)
    - Users define the number of sources, sinks, and switches.
    - A linear topology is generated automatically.
    - Routes are created between source and sink pairs with corresponding time-sensitive traffic streams.
    - Each stream are dynamically assigned key attributes including periodicity, deadline, and frame payload size.
2. TAS Scheduling considering Time Synchronization (CPLEX)
    - The TAS scheduling frameworks are fomulated as ILP methods that account for time synchronization effects.
    - CPLEX-compatible `.mod` files are automatically generated.
    - These models can be executed using IBM CPLEX optmization studio.
    - Upon sucessful execution, TAS schedule offsets are computed as decision variable outputs. 
3. GCL Formation (MATLAB)
    - The extracted CPLEX outputs are parsed to generate GCLs for each switch egress port.
    - Additional metrics related to the schedule quality known as schedulability cost are compluted.
4. Network Simulation (OMNeT++)
    - OMNeT++ compatible simulation `.ned` and `.ini` files are generated to evaluate the TAS schedules.
    - Simulations evaluate the TAS schedule performance, including the impact of synchronization behavior across devices.
5. Performance Metrics (MATLAB)
    - Simulation results are parsed and analyzed to evaluate end-to-end (e2e) latency, jitter, and overall scheduling efficiency.
    - Results are summarized in easy-to-read tables and can be exported to .csv for further post-processing.   

📌 *For a detailed list and description of the files, generated files (e.g. `.csv`,`.mod`,`.ini`,`.ned`) and folder structure refer to the [User Guide](User_Guide.md).*

## ⛏️ Topology Generation
TAS-Forge automatically generates a **linear network topology** based on user-defined input parameters, such as the number of **sources**, **sinks**, and **switches**. This topology forms the backbone of the simulation environment and influences the structure of routing paths and traffic streams.

Key Features of Topology Generation:
- **Linear Design:** The network topology is structured in a linear fashion, where traffic streams sequentially from source nodes to sink nodes through a chain of interconnected switches.
- **Route Construction:** Based on the generated topology, TAS-Forge automatically establishes communication routes between each source and sink pair. These routes specify the exact sequence of network devices (including switches) that each stream will traverse.
- **Flexible Source-Sink Mapping:** While each stream corresponds to a unique source-sink pair, the overall design allows for flexible mappings, i.e., a single source can transmit to multiple sinks, and a single sink can receive traffic from multiple sources.
- **Visual Figure:** A visual figure is generated represnting the network topology. 

The example below illustrates a simple topology consisting of 4 sources 🔺 and 3 sinks 🟢 interconnected through 3 switches 🟦.

![Simple Topology Example](images/techinical_overview_simple_topology.png)

The MATLAB command window displays the following source and sink pairs:

<pre>
Source to Sink Pairs:
source1 ---> sink1
source4 ---> sink2
source3 ---> sink3
source2 ---> sink1    
</pre>

Note that the routes are dynamically generated — not all routes traverse all three switches; each stream follows a path based on its source-sink pairing.

A ⏲️ Grand Master (GM) is automatically generated and positioned within the topology. It serves as the primary source of periodic time synchronization messages and is later modeled in the network simulation phase.

## 📡Stream & Network Parameters

### 📦 Stream Parameters
Each route in the network is associated with a **stream**, which represents a unidirectional flow of time-sensitive data frames from a source to a sink. Each stream is characterized by specific parameters essential for TAS scheduling. These include:
- **Stream ID**: A unique identifier assigned to each stream.
- **Route**: The complete path traversed by the stream, including the source, sink, and all intermediary switches.
- **Periodicity**: The frequency at which frames are generated. Periodicities are randomly assigned from a predefined set in the `T_period` array within the `generate_network_system.m` script. You can customize the stream periodicities by modifying this array.
- **Payload Size**: The size of each data frame (default: `100 Bytes`). This can be changed by editing the `payload` variable in `generate_network_system.m`. Note that the total frame size includes additional header overhead from the UDP and Ethernet layers.
- **Minimum Possible e2e latency:** The E2E latency for each stream over the route caclulcated considering only propagation, processing and transmission delays but no queuing delays. 
- **Deadline:** Each stream has a deadline constraint, set equal to the stream periodicity for simplicity. However, given the TAS simulated frameworks, the e2e latency is always equal to the minimum E2E latency or bounded based on analytical models. For further insights, refer to [1] and [2].
- **Number of Hops:** The total number of links between the source and the sink. 

💡 **Note:** Each stream operates independently, and frame timing is defined relative to the macrotick unit used in the simulation.

## References:
[1] Aviroop Ghosh, Saleh Yousefi, and Thomas Kunz. 2025. Multi-Stream TSN Gate Control Scheduling in the Presence of Clock Synchronization. In Proceedings of the 26th International Conference on Distributed Computing and Networking (ICDCN '25). Association for Computing Machinery, New York, NY, USA, 11–20. https://doi-org.proxy.library.carleton.ca/10.1145/3700838.3700847

[2] A. Ghosh, S. Yousefi, and T. Kunz, "Latency Bounds for TSN Scheduling in the Presence of Clock Synchronization," *IEEE Networking Letters*, vol. 7, no. 1, pp. 41–45, March 2025. [DOI: 10.1109/LNET.2024.3507792](https://doi.org/10.1109/LNET.2024.3507792)

