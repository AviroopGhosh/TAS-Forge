# Technical Overview
TAS-Forge is a simulation and scheduling automation tool designed for Time-Sensitive Networking (TSN). It focuses on IEEE 802.1Qbv, the Time-Aware Shaper (TAS), while also incorporating IEEE 802.1AS time synchronization into the scheduling process. The tool automatically generates linear network topologies in MATLAB, formulates Gate Control Lists (GCLs) using Integer Linear Programming (ILP) via IBM CPLEX, and evaluates scheduling performance through simulations in OMNeT++.

## 🧩 System Architecture
TAS-Forge operates across five sequential phases:
