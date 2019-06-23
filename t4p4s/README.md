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
- launch MoonGen to inject packets externally to the physical interfaces, both unidirectionally or bidirectionally. 
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
- inside the VM, launch a FloWatcher-DPDK instance to measure the forwarding throughput.

## v2v test:
- in the v2v.cfg configuration file, specify two virtual devices
- start t4p4s switch: **./start_t4p4s.sh v2v**
- launch two VMs using
  - ./v2v.sh
  - ./v2v1.sh
- on the first VM, start MoonGen to transmit packets to its virtual interface from inside.
- on the second VM, start FloWatcher-DPDK to measure forwarding throughput of t4p4s switch.

## Loopback
### 1-VNF experiment:
1. start VPP and configure the loopback forwarding rules
      * ./start_t4p4s.sh loopback
  2. start an instance of VM and attach it with two virtual interfaces
      * ./loopback.sh
  3. inside the VM, initiate DPDK and run the DPDK l2fwd sample application
      * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
      * Go to DPDK l2fwd sample application directory and launch it: ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1
      * run MoonGen scripts on the host machine from NUMA node 1:
           * Go to MoonGen directory of our repo.
           * unidirectional test: sudo ./unidirectional-test.sh 
           * bidirectional test: sudo ./bidirectional-test.sh
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
1, start t4p4s 2-VNF configuration script: ./start_t4p4s.sh loopback-2-vm
2, open a new terminal and launch the first VM: ./loopback-vm1.sh
3, open another terminal and launch the second VM: ./loopback-vm2.sh
4, inside both VMs, setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows and launch DPDK l2fwd sample application.
5, Launch MoonGen for different measurement:
   * Go to MoonGen directory of our repo.
   * unidirectional test: sudo ./unidirectional-test.sh 
   * bidirectional test: sudo ./bidirectional-test.sh
   * For latency test: sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]
