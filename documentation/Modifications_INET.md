# Modifications Required to INET
In order to simulate processing delays in network devices OMNeT++, you must modify the `EthernetLayer.ned` file in the INET framework. 

The file can be located at:
<pre>
inet/linklayer/ethernet/modular/EthernetLayer.ned
</pre>

Then make the following changes in the **source** file:

1. In the `submodules:` section add the following commands:

<pre><code class="language-ned">
 delayer: <default("PacketDelayer")> like IPacketDelayer {
  @display("p=600,407");
  }
 </default></code></pre>

2. Modify the following changes `connections:` section to include the delayer:

 <pre><code class="language-ned">
   lowerLayerIn --> { @display("m=s"); } --> delayer.in;
        delayer.out --> fcsChecker.in;
 </code></pre>
