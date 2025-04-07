# Introduction
This repository provides a framework for automatically generating Time-Aware Shaper (TAS) schedules (IEEE 802.1Qbv) for Time-Sensitive Networks (TSN), with built-in support for time synchronization based on IEEE 802.1AS. The tool ensures that generated Gate Control Lists (GCLs) align with both traffic requirements and network-wide time synchronization considerations.

# Motivation and Overview
Creating TAS schedules using linear programming methods can be highly complex, especially when working with networks that have multiple time sensitive streams. Manually defining the scheduling constraints is not only time-consuming but also difficult to scale and prone to human errors. Even small incremental changes to the network, like adding a new stream or switch, can significantly increase the number of constrains, making the process harder to manage. Moreover, TAS schedules are tightly linked to network time synchronization. Since time sensitive streams require strict determinism, GCL development requires factoring synchronization considerations while generating valid schedules adds another layer of complexity.  

TAS-Forge provides an automated framework that simplifies the design and validation of TAS schedules for TSN environments with time synchronization considerations. The tool combines MATLAB, CPLEX and OMNeT++ to generate, simulate, and analyze time sensitive traffic flows. 


# Dependencies
This version requires the following:

- MATLAB (version 2021b)
- CPLEX (version 22.1.1)
- OMNeT++ (version 6.0.3)
- INET (version 4.4)

