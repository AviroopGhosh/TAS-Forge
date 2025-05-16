# Modifications Required to INET
In order to simulate processing delays in network devices OMNeT++, you must modify the `EthernetLayer.ned` file in the INET framework. 

The 📁 file can be located at:
<pre>
inet/linklayer/ethernet/modular/EthernetLayer.ned
</pre>

Then make the following 🛠️ changes in the **source** file:

1. In the `submodules:` section add of the `.ned` file, insert the following commands:

<pre><code class="language-ned">
delayer: ```<default("PacketDelayer")```> like IPacketDelayer {
      @display("p=600,407");
}
</code></pre>

2. Make the following changes in the `connections:` section, to allow for the `lowerLayerIn` to pass through the `delayer` module:

 <pre><code class="language-ned">
   lowerLayerIn --> { @display("m=s"); } --> delayer.in;
   delayer.out --> fcsChecker.in;
 </code></pre>

Feel free to adjust the icon positioning in the **design** tab for better visual alignment. 

🔑 **Key:** Ensure correct indentation and alignment when modifying the `.ned` file to maintain INET compatibility.

💡 **Important:** This modification ensures that Ethernet-layer packets experience the intended **processing delays** during simulation. Be sure to **save and rebuild** your INET project after making changes. 

🧰 **Note:** TAS-Forge only simulates processing delays in switches. 
