# VPP experiments
Install VPP according to instructions on official website. The VPP version we used was VPP 19.04.

## p2p test
### Steps:
* Start an instance of VPP and attach two physical ports to it: 
    * **./startup_vpp.sh p2p**
      Current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify it to your respective PCI addresses for reproduction.
    * Open another terminal and configure VPP l2patch rules: 
    
      **./vppctl_p2p.sh l2patch**
      
* Instantiate MoonGen for throughput (unidirectional/bidirectional) and latency tests:
    * Go to the MoonGen repo directory:
    
      **cd ../moongen/**
      
    * For unidirectional throughput test:
    
      **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      
    * For bidirectional throughput test: 
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
      
    * For latency test: 
    
      **sudo ./latency-test.sh -r [packet rate (Mbps)]**
    
## p2v test
### Steps:
* Start VPP, bind a physical port and a vhost-user port to VPP, then configure forwarding rules between them:
    
    * **./startup_vpp.sh p2v**
    * Open another terminal and configure VPP l2patch rules: 
    
      **./vppctl_p2v.sh l2patch**
* Start virtual machine using QEMU/KVM and attach one virtual interface: 
   **./p2v.sh**
* Login to the VM, setup DPDK, FloWatcher-DPDK and MoonGen as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
* For unidirectional test:
    * Inside the VM, to to FloWatcher-DPDK directory and instantiate FloWatcher-DPDK to measure unidrectional throughput: 
    
      **cd path/to/FloWatcher-DPDK; ./build/FloWatcher-DPDK -c 3**
    * On the host side, go to MoonGen repo directory and start its unidirectional test script on NUMA node 1: sudo 
      
      **cd ../moongen; ./unidirectional-test.sh -s [packet size (Bytes)]**
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: 
    
      **cd path/to/MoonGen**
    * Execute the MoonGen TX/RX script: 
    
      **./build/MoonGen ../script/txrx.lua -s [packet size (Bytes)]**
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: 
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**

## v2v test
### Steps:
* Start VPP and configure the forwarding rules between two VMs
    * **./startup_vpp.sh v2v**
    * Open another terminal and configure VPP l2patch rules: 
    
      **./vppctl_v2v.sh l2patch**
* Start two QEMU/KVM virtual machines:
    * Start VM1: **./v2v1.sh**
    * Start VM2: **./v2v.sh**     
* On VM1, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
    * Go to MoonGen directory and run its l2-load-latency sample application: 
    
      **./build/MoonGen example/l2-load-latency.lua 0 0**
* On VM2, setup DPDK, as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
    * For unidirectional throughput test:
    
     * Go to FloWatcher-DPDK installation directory and launch it: 
    
       **cd path/to/FloWatcher-DPDK; ./build/FloWatcher-DPDK -c 3**
    * For bidirectional throughput test:
     * Go to MoonGen installation directiory and launch it:
       
       **cd path/to/MoonGen; ./build/MoonGen ../script/txrx.lua -s [packet size (Bytes)]**
       
    * For latency test:
      .....
  
## Loopback
### 1-VNF experiment:
  1. start VPP and configure the loopback forwarding rules
      * **./startup_vpp.sh loopback**
      * Open another terminal and configure VPP l2patch rules: 
      
        **./vppctl_loopback-2-vm.sh l2patch**
  2. start an instance of VM and attach it with two virtual interfaces
  
      **./loopback.sh**
  3. inside the VM, initiate DPDK and run the DPDK l2fwd sample application
      * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
      * Go to DPDK l2fwd sample application directory and launch it: 
      
         **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
      * run MoonGen scripts on the host machine from NUMA node 1:
       * Go to MoonGen directory of our repo:
       
         **cd ../moongen/**
       * For unidirectional throughput test: 
       
         **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
       * For bidirectional throughput test: 
       
         **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
1. start VPP 2-VNF configuration script
   * **./startup_vpp loopback2**
   * Open another terminal and configure VPP l2patch rules: 
   
      **./vppctl_loopback2.sh l2patch**
2. open a new terminal and launch the first VM: 

   **./loopback-vm1.sh**
3. open another terminal and launch the second VM: 

   **./loopback-vm2.sh**
4. inside both VMs, setup DPDK detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md) and launch DPDK l2fwd sample application.
   **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
5. Launch MoonGen for different measurement:
      * Go to MoonGen directory of our repo:
      
        **cd ../moongen/**
      * unidirectional test: 
      
         **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      * bidirectional test: 
      
         **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
      * For latency test: 
      
         **sudo ./latency-test.sh -r [packet rate (Mbps)]**
         
  
