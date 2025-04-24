# Technical Overview
TAS-Forge is a simulation and scheduling automation tool designed for Time-Sensitive Networking (TSN). It focuses on IEEE 802.1Qbv, the Time-Aware Shaper (TAS), while also incorporating IEEE 802.1AS time synchronization into the scheduling process. The tool automatically generates linear network topologies in MATLAB, formulates Gate Control Lists (GCLs) using Integer Linear Programming (ILP) via IBM CPLEX, and evaluates scheduling performance through simulations in OMNeT++.

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
    - Simulation results are parsed and analyzed to evaluate end-to-end latency, jitter, and overall scheduling efficiency.
    - Results are summarized in easy-to-read tables and can be exported to .csv for further post-processing.   

📌 *For a detailed list and description of the files, generated files (e.g. `.csv`,`.mod`,`.ini`,`.ned`) and folder structure refer to the [User Guide](User_Guide.md).*

## ⛏️ Topology Generation
Given the 
