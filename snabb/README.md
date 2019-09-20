# Snabb experiments
The scripts directory contains the snabb lua scripts to configure the workflows for different test scenarios.

## p2p test
### Steps:
* Make ${SNABB_DIR}/src/program/p2p/ directory and copy the scripts/p2p.lua script to it.
* Recompile snabb program according to (https://github.com/snabbco/snabb#how-do-i-get-started).
* Start Snabb and configure rules cross-connect rules between two physical ports: 
    * For unidirectional test: 
    
      **./start-snabb.sh p2p**
    * For bidirectional test:
    
      **./start-snabb.sh p2p-bi**
  
  Note that current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify it to your respective PCI addresses for reproduction.

* Instantiate MoonGen to TX/RX the performance for throughput (unidirectional/bidirectional) and latency:
    * Go to the MoonGen repo directory
    * For unidirectional test: 
    
      **sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]**
    * For bidirectional test:
    
      **sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]**
    * For latency test:
      
      **sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]**
    
## p2v test
### Steps:
* Make ${SNABB_DIR}/src/program/p2v/ directory and copy the scripts/p2v.lua script to it.
* Recompile snabb program according to (https://github.com/snabbco/snabb#how-do-i-get-started).
* Start Snabb, bind a physical port and a vhost-user port to Snabb, then configure forwarding rules between them:
    * For unidirectional test: 
    
      **./start-snabb.sh p2v**
    * For bidirectioanl test:
    
      **./start-snabb.sh p2v-bi**
* Start virtual machine using QEMU/KVM and attach one virtual interface: 

  **./p2v.sh**
* Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
* For unidirectional test:
    * Inside the VM, to to FloWatcher-DPDK directory and instantiate FloWatcher-DPDK to measure unidrectional throughput:
    
      **./build/FloWatcher-DPDK -c 3**
    * On the host side, go to MoonGen repo directory and start its unidirectional test script on NUMA node 1: 
    
      **sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]**
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: 
    
      **cd /root/MoonGen**
    * Execute the MoonGen TX/RX script: 
    
      **./build/MoonGen ../script/txrx.lua -r [packet rate (Mpps)] -s [packet size (Bytes)]**
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: 
    
      **sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]**

## v2v test
### Steps:
* Make ${SNABB_DIR}/src/program/v2v/ directory and copy the scripts/v2v.lua script to it.
* Recompile snabb program according to (https://github.com/snabbco/snabb#how-do-i-get-started).
* Start Snabb, bind a physical port and a vhost-user port to Snabb, then configure forwarding rules between them:
    * For unidirectional test: 
    
      **./start-snabb.sh v2v**
    * For bidirectioanl test: 
    
      **./start-snabb.sh v2v-bi**
* Start two QEMU/KVM virtual machines:

   **./v2v1.sh**   # start VM1 which transmits packets to VM2
   
   **./v2v.sh**     # start VM2 which receives packet from VM1 and measures the throughput
* On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to MoonGen directory and run its l2-load-latency sample application: 
    
      **./build/MoonGen example/l2-load-latency.lua 0 0**
* On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030), we start an instance of FloWatcher-DPDK to measure the inter-VM throughput:
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to FloWatcher-DPDK installation directory and launch it using: 
      
      **./build/FloWatcher-DPDK -c 3**
  
## Loopback
### 1-VNF experiment:
* Make ${SNABB_DIR}/src/program/loopback/ directory and copy the scripts/loopback.lua to it.
* Recompile snabb program according to (https://github.com/snabbco/snabb#how-do-i-get-started).
* Start Snabb, bind a physical port and a vhost-user port to Snabb, then configure forwarding rules between them:
    * For unidirectional test: 
    
      **./start-snabb.sh loopback**
    * For bidirectioanl test: 
    
      **./start-snabb.sh loopback-bi**
* start an instance of VM and attach it with two virtual interfaces:

   **./loopback.sh**
* inside the VM, initiate DPDK and run the DPDK l2fwd sample application
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to DPDK l2fwd sample application directory and launch it: 
      
      **./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
    * run MoonGen scripts on the host machine from NUMA node 1:
      * Go to MoonGen directory of our repo.
      * unidirectional test: 
           
       **sudo ./unidirectional-test.sh**
      * bidirectional test: 
      
       **sudo ./bidirectional-test.sh**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
* Make ${SNABB_DIR}/src/program/loopback2/ directory and copy the scripts/loopback2.lua to it.
* Recompile snabb program according to (https://github.com/snabbco/snabb#how-do-i-get-started).
* Start Snabb, bind a physical port and a vhost-user port to Snabb, then configure forwarding rules between them:
    * For unidirectional test: 
    
      **./start-snabb.sh loopback2**
    * For bidirectioanl test: 
    
      **./start-snabb.sh loopback2-bi**
* open a new terminal and launch the first VM: 

   **./loopback-vm1.sh**
* open another terminal and launch the second VM: 

   **./loopback-vm2.sh**
* inside both VMs, setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows and launch DPDK l2fwd sample application.
* Launch MoonGen for different measurement:
   * Go to MoonGen directory of our repo.
   * unidirectional test: 
   
      **sudo ./unidirectional-test.sh**
   * bidirectional test:
   
      **sudo ./bidirectional-test.sh**
   * For latency test:
   
      **sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]**

