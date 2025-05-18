# 🥅 Goal
This showcase provides a step-by-step walkthrough of TAS-Forge’s workflow for comparing two scheduling frameworks applied to the same network topology. It demonstrates the full TAS-Forge generation process using both the **Network-Derived Clock Drift Adjustment (NCA)** and **Worst-Case Adjustment (WCA)** scheduling methods.

The network topology considered consists of **6 switches**, **5 sources** and **5 sinks**.  

The showcase highlights each major phase including:
- Generation of the network topology and time-sensitive streams.
- Formulation of TAS scheduling constraints using CPLEX for both the NCA and WCA scheduling methods.
- Generation of Gate Control Lists (GCLs) for the NCA method.
- Preparation and execution of simulation files for OMNeT++ for the NCA scheduling method.
- Generation of GCLs for the WCA method.
- Preparation and execution of simulation files for OMNeT++ for the WCA scheduling method.
- Analysis of the results from both scheduling frameworks.  

This guide demonstrates how to replicate the showcased example using TAS-Forge. 
