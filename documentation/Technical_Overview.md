# Technical Overview
TAS-Forge is a simulation and scheduling automation tool designed for Time-Sensitive Networking (TSN). It focuses on IEEE 802.1Qbv, the Time-Aware Shaper (TAS), while also incorporating IEEE 802.1AS time synchronization into the scheduling process. The tool automatically generates linear network topologies in MATLAB, formulates Gate Control Lists (GCLs) using Integer Linear Programming (ILP) via IBM CPLEX, and evaluates scheduling performance through simulations in OMNeT++.

## 🧩 System Architecture
TAS-Forge operates across five sequential phases:

1. Toplogy & Stream Generation (MATLAB)
  - Users define the number of sources, sinks, and switches.
  - A linear topology is generated automatically.
  - Routes are created between source and sink pairs with corresponding time-sensitive traffic streams.
  - Each stream are assigned periodicity, deadline, and payload size.
  
3. TAS Scheduling considering Time Synchronization (CPLEX)
4. GCL Formation (MATLAB)
5. Network Simulation (OMNeT++)
6. Performance Metrics (MATLAB) 
