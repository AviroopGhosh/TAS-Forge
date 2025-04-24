# Technical Overview
TAS-Forge is a simulation and scheduling automation tool designed for Time-Sensitive Networking (TSN). It focuses on IEEE 802.1Qbv, the Time-Aware Shaper (TAS), while also incorporating IEEE 802.1AS time synchronization into the scheduling process. The tool automatically generates linear network topologies in MATLAB, formulates Gate Control Lists (GCLs) using Integer Linear Programming (ILP) via IBM CPLEX, and evaluates scheduling performance through simulations in OMNeT++.

## 🧩 System Architecture
TAS-Forge operates across five sequential phases:

1. Toplogy & Stream Generation (MATLAB)
    - Users define the number of sources, sinks, and switches.
    - A linear topology is generated automatically.
    - Routes are created between source and sink pairs with corresponding time-sensitive traffic streams.
    - Each stream are dynamically assigned a periodicity, deadline, and frame payload size.
  
2. TAS Scheduling considering Time Synchronization (CPLEX)
    - The TAS scheduling frameworks are fomulated as ILP methods that account for time synchronization effects.
    - CPLEX-compatible `.mod` files are automatically generated.
    - These models can be executed using IBM CPLEX optmization studio.
    - Upon sucessful execution, TAS schedule offsets are computed as decision variable outputs. 
3. GCL Formation (MATLAB)
    - The CPLEX decision variable outputs are used to compute GCLs.
    - Metrics related to the schedulability quality are calculated. 
6. Network Simulation (OMNeT++)
7. Performance Metrics (MATLAB) 
