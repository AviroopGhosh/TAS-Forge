# Issues and Known Limitations
TAS-Forge is designed to provide a robust and flexible framework for generating TAS schedules. However, the tool is evolving and like any evolving tool, it has a number of known limitations with areas for improvement. These are outlined below to provide transparency and guide future development.

## 📏 Linear Topology
TAS-Forge currently supports only linear topologies for simulation. While this structure simplifies analysis and serves as a useful baseline, real-world TSN deployments often involve more complex topologies such as ring, tree, or mesh, particularly to support redundancy and fault tolerance etc. Extending TAS-Forge to support these topologies is left as future work to enable more comprehensive and application-relevant studies.

## ✋Limitations on Certain Values
While TAS-Forge offers users flexibility to configure various parameters, such as the number of devices, certain other value selections may lead to functional or performance limitations. The specific constraints and their potential impact are detailed below.

### ⏲️Synchronization Periodicity:
By default, TAS-Forge uses a synchronization periodicity of 125 ms, as recommended by IEEE 802.1AS. This value can be modified to other log2-based intervals, such as:
- 2⁻⁴ = 62.5 ms
- 2⁻¹ = 0.5 s

To adjust this, modify the following line in 'generate_network_system.m':
<pre>
T_sync = 0.125; % Synchronization periodicity in seconds  
</pre>

Note: Reducing the synchronization periodicity (e.g., below 125 ms) may cause synchronization messages to interfere with time-sensitive traffic, potentially leading to frame collisions or scheduling violations. Care should be taken when modifying this parameter.
