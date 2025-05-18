package TSN_Multi_Stream;

import inet.networks.base.WiredNetworkBase;
import inet.node.ethernet.Eth1G;
import inet.node.ethernet.EthernetSwitch;
import inet.node.tsn.TsnSwitch;
import inet.node.inet.StandardHost;
import inet.node.tsn.TsnDevice;

network TS_network extends WiredNetworkBase
{
    @display("bgb=9000,9000");
    submodules:
        switch1: TsnSwitch {
            @display("p=6200.00,6142.86");
        }
        switch2: TsnSwitch {
            @display("p=3600.00,5285.71");
        }
        switch3: TsnSwitch {
            @display("p=3600.00,4428.57");
        }
        switch4: TsnSwitch {
            @display("p=3600.00,3571.43");
        }
        switch5: TsnSwitch {
            @display("p=2300.00,2714.29");
        }
        sink1: TsnDevice {
            @display("p=3600.00,2714.29");
        }
        sink4: TsnDevice {
            @display("p=4900.00,2714.29");
        }
        switch6: TsnSwitch {
            @display("p=1650.00,1857.14");
        }
        sink2: TsnDevice {
            @display("p=2950.00,1857.14");
        }
        sink5: TsnDevice {
            @display("p=4250.00,1857.14");
        }
        sink3: TsnDevice {
            @display("p=1650.00,1000.00");
        }
        source1: TsnDevice {
            @display("p=4900.00,7000.00");
        }
        source2: TsnDevice {
            @display("p=6200.00,7000.00");
        }
        source3: TsnDevice {
            @display("p=7500.00,7000.00");
        }
        source4: TsnDevice {
            @display("p=1000.00,7000.00");
        }
        source5: TsnDevice {
            @display("p=2300.00,7000.00");
        }
        GM1: TsnDevice {
            @display("p=3600.00,7000.00");
        }
    connections:
        switch1.ethg++ <--> Eth1G <--> switch2.ethg++;
        switch2.ethg++ <--> Eth1G <--> switch3.ethg++;
        switch3.ethg++ <--> Eth1G <--> switch4.ethg++;
        switch4.ethg++ <--> Eth1G <--> switch5.ethg++;
        switch4.ethg++ <--> Eth1G <--> sink1.ethg++;
        switch4.ethg++ <--> Eth1G <--> sink4.ethg++;
        switch5.ethg++ <--> Eth1G <--> switch6.ethg++;
        switch5.ethg++ <--> Eth1G <--> sink2.ethg++;
        switch5.ethg++ <--> Eth1G <--> sink5.ethg++;
        switch6.ethg++ <--> Eth1G <--> sink3.ethg++;
        source1.ethg++ <--> Eth1G <--> switch1.ethg++;
        source2.ethg++ <--> Eth1G <--> switch1.ethg++;
        source3.ethg++ <--> Eth1G <--> switch1.ethg++;
        source4.ethg++ <--> Eth1G <--> switch2.ethg++;
        source5.ethg++ <--> Eth1G <--> switch2.ethg++;
        GM1.ethg++ <--> Eth1G <--> switch2.ethg++;
}
