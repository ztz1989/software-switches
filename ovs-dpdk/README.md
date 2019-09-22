# OVS-DPDK Experiments
Install Open vSwitch according to the instructions on the offical website. The version we used was **Open vSwitch 2.11.90**.

## p2p test 
In p2p test, we cross-connect two physical interfaces using OVS-DPDK
Detailed steps to repeat our experiments are listed as follows:

* Start OVS and configure cross-connect rules between the two physical ports by executing **./ovs-p2p.sh**

  Current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify variables $PCI0 and $PCI1 to your respective PCI addresses for reproduction.

* Instantiate MoonGen to transmit packets and measure throughput/latency:
    * Go to the MoonGen repo directory
    
      **cd ../MoonGen**
    * For unidirectional throughput test: 
    
      **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      
      Since our NICs are 10Gbps, so the specified packet rate is always 10Gbps for us. As for packet sizes, we use 64B, 256B,       and 1024B. Note that the specified sizes should be 64B, 252B, and 1020B respectively due to checksum offloading.
      
    * For bidirectional test: 
    
      **sudo ./bidirectional-test.sh -s [packet size (in Bytes)]**
      
      This script was customized from MoonGen's [l2-load-latency](https://github.com/emmericp/MoonGen/blob/master/examples/l2-load-latency.lua) app, it injected packets towards OVS-DPDK's two physical interfaces simultaneously and measured the aggregated throughput.
      
    * For latency test, we utilized MoonGen's hardware timestamping feature. In particular, MoonGen was configured to mix specially marked UDP packets inside normal traffic load and collect them from the RX end to calculate the round-trip-time (RTT). To perform the test, simply execute the latency-test.sh script, which will do all the work: 
    
      **sudo ./latency-test.sh -r [packet rate (Mbps)] -s [packet size (in Bytes)]**
      
      Note that we only used 64B packets in our experiments and varied the packet rate among [0.1, 0.5, 0.99] of the maximal sustainable throughput. In particular, we firstly transmit at 10Gbps rate to obtain the maximal sustainable throughput `R+`. Then we repeat the same experiments with [0.1, 0.5, 0.99] of `R+` respectively.  
By default, MoonGen will output the results in the "histogram.csv" file in current directory.

More details about MoonGen scripts used in our tests can be found [here](https://github.com/ztz1989/software-switches/tree/artifacts/moongen).

## p2v test
In p2v test, we configure OVS-DPDK to rely packets between the physical interface and the VNF running inside VM. 

### Steps:
* Start OVS, bind a physical port and a vhost-user port to OVS-DPDK, and configure forwarding rules to cross-connect them:

  **./ovs-p2v.sh**
  
  Note that value of $PCI0 variable needs to be modifed to the PCI address of your NIC interface.
  
* Start a virtual machine using QEMU/KVM and create a virtio virtual interface. Then attach it to OVS-DPDK through the vhost-user backend: 

  **./p2v.sh**
  
* Login to the VM and setup DPDK, MoonGen, and FloWatcher-DPDK, as explained [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md)

* For unidirectional throughput test:
    * On the host side, go to the moongen directory of this repo and start its unidirectional test script: 
    
      **cd ../moongen/**
    
      **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      
    * Inside the VM, go to FloWatcher-DPDK installation directory and start FloWatcher-DPDK to measure the unidrectional throughput:

      **./build/FloWatcher-DPDK -c portmask**
      
      FloWatcher-DPDK requires two cores to function, specify it accordingly, e.g., 0x3. 
      
* For bidirectional throughput test:
    * Inside the VM, go to MoonGen directory: 
    
      **cd /root/MoonGen**
      
    * Execute the MoonGen TX/RX script: 
    
      **./build/MoonGen ../script/txrx.lua -s [packet size (Bytes)]**
    * On the host side, run MoonGen bidirectional test scripts: 
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**

* We didn't perform latency test for p2v scenario, as explained in our paper.

## v2v test
In v2v scenario, we configure OVS-DPDK to rely packets between two VMs.
### Steps:
* Start OVS, create two vhost-user interfaces, and configure the forwarding rules between them:
  
  **./ovs-v2v.sh**
* Start two QEMU/KVM VMs by opening two termials:

  * In the first terminal, start VM1: **./v2v1.sh**    
  
  * In the second terminal, start VM2: **./v2v.sh**

  Inside both VMs, setup DPDK along with all the other tools, as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
  
* For unidirectional throughput test:
  * On VM1, setup and start MoonGen's l2-load-latency sample application to inject packets towards OVS-DPDK: 
    
    **cd path/to/MoonGen; ./build/MoonGen example/l2-load-latency.lua 0 0**
      
  * On VM2, start FloWatcher-DPDK:
   
    **cd path/to/FloWatcher-DPDK; ./build/FloWatcher-DPDK -c 3**
* For bidirectional throughput test:
    * On VM1, do the same as unidirectional test
    * On VM2, start another instance of MoonGen as follows:
    
      **cd path/to/MoonGen; ./build/MoonGen example/l2-load-latency.lua 0 0**

* For latency test, we run MoonGen's software timestamping script inside VM. Although not as accurate as hardware timestamping, it can still provide a comparison among different software switches. 

## Loopback test
In this scenario, we configure OVS-DPDK to forward packets for a chain of VNFs, each of which is hosted by a VM. Packets are injected through one physical interfaces and received from the other physical interface.

### 1-VNF experiment:
1. start OVS and configure the 1-VNF forwarding rules:

   **./ovs-loopback.sh**
   
   This script creates two vhost-user interfaces on OVS-DPDK. The interfaces will be attached to VM. Modify variables $PCI0 and $PCI1 to the PCI addresses of physical interfaces on your server. The forwarding rules are also configured to match the in_port of each packet.
   
2. start an instance of VM and create two virtio virtual interfaces: **./loopback.sh**
   
3. inside the VM, initiate DPDK and run the DPDK l2fwd sample application, as explained [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
  * Go to DPDK l2fwd sample application directory and launch it: 
      
    **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
  * On the host side, run MoonGen scripts on the host machine from NUMA node 1:
   * unidirectional test: 
           
     **sudo ./unidirectional-test.sh**
   * bidirectional test: 
           
     **sudo ./bidirectional-test.sh**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
1. start OVS 2-VNF configuration script: 

   **./ovs-loopback-2-vm.sh**
2. open a new terminal and launch the first VM:
    
   **./loopback-vm1.sh**
3. open another terminal and launch the second VM: 

   **./loopback-vm2.sh**
   
4. inside both VMs, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md) and launch DPDK l2fwd sample application.
5. Launch MoonGen for different measurement:
   * Go to MoonGen directory of our repo.
   * unidirectional test: 
   
     **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
   * bidirectional test: 
   
     **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
   * For latency test: 
   
     **sudo ./latency-test.sh -r [packet rate (Mbps)] -s [packet size (Bytes)]**

## Clear the flow table and terminate all OVS threads
  **./terminate_ovs-dpdk.sh**
 
  This script terminates both ovs daemon and ovsdb threads. This step is necessary before running any experiment for other software switches, just in case of race conditions on the interfaces or cores.
