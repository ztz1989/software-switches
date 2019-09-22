# Performance test for the t4p4s switch

This directory contains scripts to perform p2p, p2v and v2v tests. More details about t4p4s can be found in its 
[repository](https://github.com/P4ELTE/t4p4s). Our work aims at providing a preliminary performance analysis of t4p4s as dataplane of NFV platform. 

Note that due to some unknown issues in t4p4s's boostrap-t4p4s.sh script during installation, we cannot specify the version of DPDK for t4p4s, and it just uses the newest version of DPDK, which is now 19.05. A dirty way to specify a DPDK version is assigning the intended version specifically to $DPDK_VSN and $DPDK_FILEVSN variables in the scripts, for example, if we want to use DPDK 18.11, then edit the variables as follows:

DPDK_VSN="18.11"
DPDK_FILEVSN="18.11.1"

Furthermore, there seems to be a bug in the llvm libraries. we needed to remove existing libraries and install the 3.9

```
 sudo apt-get remove llvm-3.8-runtime llvm-runtime 
 sudo apt-get install llvm-3.9*
```

A more comprehensive test description will be added soon. Stay tuned!!!

## p2p test:
- in the start_t4p4s.sh script, modify the $T4P4s_DIR to the corresponding path on your server
- in p2p.cfg configuration file, line 8: change the PCI addresses (after -w) to the physical interfaces to be attached to t4p4s switch on your server. 
  Note that this is just the DPDK whitelist commandline option. The specified interfaces will be granted a DPDK device number
  starting from 0.
- start t4p4s switch for p2p test: **./start_t4p4s.sh p2p**
- Instantiate MoonGen for throughput (unidirectional/bidirectional) and latency tests:
    * Go to the MoonGen repo directory:
    
      **cd ../moongen/**
      
    * For unidirectional throughput test:
    
      **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      
    * For bidirectional throughput test: 
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
      
    * For latency test: 
    
      **sudo ./latency-test.sh -r [packet rate (Mbps)]**

Note that t4p4s uses a default Match/Action table to forward packets. The default Match field is the destination MAC address. 
  The table is shown here. Part of it looks like this:
  
  | Dst MAC  | Out_port |
  |------------------|--|
  |aa:cc:dd:cc:00:01 | 1|
  |aa:bb:bb:aa:00:01 | 0|
  
  To make the switch forward packets properly, **the injected packets must have the corrsponding destination MAC address and 
  the matched out_port cannot be the same as in_port, or t4p4s will simply crash.**
  
## p2v test:
Before starting p2v test, one thing to emphasize about t4p4s is the fact that it is mainly designed to work with physical NICs. By default, it cannot work with virtual interfaces, since a lot of hardware features (offloading, RSS, etc.) utilized by t4p4s switch are not natively supported by virtual interfaces such as virtio-net, etc. We comment out these unsupported features in the dpdk_lib_init_hw.c file under src/hardware_dep/dpdk/data_plane directory of the t4p4s repo, and recompile the source code so as to make t4p4s compatible with virtual interfaces. 

Steps to reproduce p2v test for t4p4s is as follows:
- in the p2v.cfg configuration file, line 8: specify your intended virtual device with the Unix socket path through the DPDK --vdev option. Also whitelist the PCI address of the physical interface using -w option.
- start t4p4s switch: **./start_t4p4s.sh p2v**
- launch a VM instance with a virtio interface connected through the specified socket path, using the p2v.sh script.
- launch MoonGen and inject traffic to the specified physical interface.
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

## v2v test:
* In the **v2v.cfg** configuration file, specify two virtual devices
* start t4p4s switch: **./start_t4p4s.sh v2v**
* launch two VMs:
  - Start VM1: **./v2v.sh**
  - Start VM2: **./v2v1.sh**
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
1. start VPP and configure the loopback forwarding rules: **./start_t4p4s.sh loopback**
2. start an instance of VM and attach it with two virtual interfaces: **./loopback.sh**
3. inside the VM, initiate DPDK and run the DPDK l2fwd sample application
      * Login to the VM and setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
      * Go to DPDK l2fwd sample application directory and launch it: 
      
        **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
      * run MoonGen scripts on the host machine from NUMA node 1:
       * Go to MoonGen directory of our repo:
       
         **cd ../moongen/
       * unidirectional test: 
       
         **sudo ./unidirectional-test.sh  -s [packet size (Bytes)]**
       * bidirectional test: 
       
         **sudo ./bidirectional-test.sh  -s [packet size (Bytes)]**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
1. start t4p4s 2-VNF configuration script:

   **./start_t4p4s.sh loopback-2-vm**
2. open a new terminal and launch the first VM: 

   **./loopback-vm1.sh**
3. open another terminal and launch the second VM: 

   **./loopback-vm2.sh**
   
4. inside both VMs, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md) and launch DPDK l2fwd sample application:

   **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
5. Launch MoonGen for different measurement:
   * Go to MoonGen directory of our repo:
   
     **cd ../moongen**
   * unidirectional test:
   
     **sudo ./unidirectional-test.sh**
   * bidirectional test:
   
     **sudo ./bidirectional-test.sh**
   * For latency test: 
   
     **sudo ./latency-test.sh -r [packet rate (Mbps)]**
