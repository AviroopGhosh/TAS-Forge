# 🚀 Introduction
This repository provides a framework for automatically generating Time-Aware Shaper (TAS) schedules (IEEE 802.1Qbv) for Time-Sensitive Networks (TSN), with built-in support for time synchronization based on IEEE 802.1AS. The tool ensures that generated Gate Control Lists (GCLs) align with both traffic requirements and network-wide time synchronization considerations.

# 🎯 Motivation and Overview
Creating TAS schedules using linear programming methods can be highly complex, especially when working with networks that have multiple time sensitive streams. Manually defining the scheduling constraints is not only time-consuming but also difficult to scale and prone to human errors. Even small incremental changes to the network, like adding a new stream or switch, can significantly increase the number of constraints, making the process harder to manage. Moreover, TAS schedules are tightly linked to network time synchronization. Since time sensitive streams require strict determinism, GCL development requires factoring synchronization considerations while generating valid schedules adds another layer of complexity.  

TAS-Forge provides an automated framework that:
- Simplifies the design and validation of TAS schedules.
- Integrates time synchronization considerations such as clock drift and synchronization periodicity.
- Leverages MATLAB, CPLEX and OMNeT++ to generate, simulate, and analyze time sensitive traffic flows. 

# 🌠 Key Features
Key features of TAS-Forge have been described below. 

## User-Defined Input
-	Easy specification of the number of switches, sources and sinks to define the structure of the network.
-	Inputs are provided via a simple dialog box, for quick and easy setup process. 

## Automatic Topology & Stream Generation 
-	Based on user specification, the tool generates a linear network topology. 
-	Routes are automatically created to connect each source to a corresponding sink. 
-	A single source can transmit to multiple sinks, and/or a single sink can receive traffic from multiple sources, allowing for flexible and realistic traffic scenarios.
-	Each route is associated with a stream, and each stream is automatically assigned:
    -	Payload size of frames. 
    -	Transmission periodicity. 
    -	Deadline for streams. 

## IEEE 802.1AS Time Synchronization Modeling
-	The framework simulates realistic clock behaviour by assigning each device a random clock drift within specific bounds. 
-	Devices synchronize using a defined synchronization periodicity, simulating realistic timing behaviour.
-	The model enables analyzing the impact of synchronization on TAS scheduling.
-	These are critical aspects often overlooked in TAS scheduling frameworks. 

## TAS Scheduling Frameworks
-	Users can choose from a suite of TAS scheduling frameworks to apply to schedule generation. 
-	This makes it easy to test and compare different scheduling frameworks under identical network conditions.
-	Automated CPLEX scripts are provided to eliminate the need for manual configuration and parameter setting. 

## OMNeT++ File Generation
-	The tool also automatically generates the required the .ned and .ini files based on:
    -	The generated topology
    -	The scheduling decisions 
    -	Time synchronization parameters
-	These filed can be directed used for simulation in the network simulator tool OMNeT++. 

## Simulation Output & Analysis
-	After executing the files in OMNeT++, the results can be:
    -	Parsed and analyzed in MATLAB. 
    -	Exported in .csv structure for further inspection and analysis. 
-	The simulator also provides insights into network performance, latency and schedule effectiveness. 

## 🪄 Example: Multi-Stream Scheduling
The diagram below illustrates an example network scenario supported by TAS-Forge. It shows how multiple source-to-sink routes (with sources of time-sensitive traffic, labeled as src) are grouped into time-sensitive streams and scheduled across a linear topology using TAS scheduling techniques. The placement of a Grandmaster (GM) node within the topology highlights the tool’s consideration of time synchronization, as defined by IEEE 802.1AS.

![Multi-stream TSN example](documentation/images/example_topology_1.png)

# ❗Dependencies
This version requires the following software versions:

Tool | Version
MATLAB | R2021b or later
IBM CPLEX | 22.1.1 or later
OMNeT++ | 6.0.3 or later
INET | 4.4

# 📚 Documentation
The following documentation covers key aspects of TAS-Forge, including how to use, system architecture, and known limitations:

- [User Guide](documentation/User_Guide.md) - Step-by-step instructions of how to use TAS-Forge. 
- [Technical Overview](documentation/Technical_Overview.md) - In-depth explanation of TAS-Forge's design and system model. 
- [Known Issues and Limitations](documentation/Issues_and_Limitations.md) - Current limitations and potential areas of improvement in the future.
- [Modifications Required to INET](documentation/Modifications_INET.md) - Modifications required to INET to implement the OMNeT++ component of TAS-Forge.
