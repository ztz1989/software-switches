# VPP experiments

## p2p test
### Steps:
* Start VPP and configure rules cross-connect rules between two physical ports: ./startup_vpp.sh p2p
    * Current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify it to your respective PCI addresses for reproduction.
* Instantiate MoonGen to TX/RX the performance for throughput (unidirectional/bidirectional) and latency:
    * Go to MoonGen directory: cd ../moongen
    * For unidirectional test: sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For bidirectional test: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For latency test: sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]
    
## p2v test
### Steps:
* Start VPP, bind a physical port and a vhost-user port to OVS-DPDK, then configure forwarding rules between them:
    * ./startup_vpp.sh p2v
* Start virtual machine using QEMU/KVM and attach one virtual interface: ./p2v.sh
* Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
* For unidirectional test:
    * Inside the VM, go to FloWatcher-DPDK directory and instantiate FloWatcher-DPDK to measure unidrectional throughput as follows: ./build/FloWatcher-DPDK -c 3
    * On the host side, go to MoonGen directory of our repo and start its unidirectional test script on NUMA node 1: cd ../moongen & sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: cd /root/MoonGen
    * Execute the MoonGen TX/RX script: ./build/MoonGen ../script/txrx.lua -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]

## v2v test
### Steps:
* Start VPP and configure the forwarding rules between two VMs
    * ./startup_vpp.sh v2v
* Start two QEMU/KVM virtual machines:
    * ./v2v1.sh    # start VM1 which transmits packets to VM2
    * ./v2v.sh     # start VM2 which receives packet from VM1 and measures the throughput
* On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
    * Setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to the MoonGen installation directory inside the virtual machine
    * ./build/MoonGen example/l2-load-latency.lua 0 0
* On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030), we start an instance of FloWatcher-DPDK to measure the inter-VM throughput:
    * Setup the virtual machine according to https://github.com/ztz1989/software-switches#virtualization-environment.
    * Go to FloWatcher diretory and launch it to measure throughtput: ./build/FloWatcher-DPDK -c 3
  
## Loopback
### Steps:
1. start VPP and configure the loopback forwarding rules
      * ./startup_vpp.sh loopback
  2. start an instance of VM and attach it with two virtual interfaces
      * ./loopback.sh
  3. inside the VM, initiate DPDK and run the DPDK l2fwd sample application
      * Setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
      * Go to dpdk l2fwd directory, usually it is under: ${DPDK_HOME}/examples/l2fwd.
      * ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1
      * run MoonGen scripts on the host machine from NUMA node 1:
           * cd /root/MoonGen
           * unidirectional test: sudo ./unidirectional-test.sh 
           * bidirectional test: sudo ./bidirectional-test.sh
      
### Containers (To be completed)
* Physical <-> Virtual test
   * start OVS and configure forwarding rules
      * ./ovs-nic1-vm1.sh
   * start an instance of FlowMown-DPDK container and login
      * ./flowmown-docker.sh
   * start FlowMown-DPDK inside the container
      * ./build/FlowMown-DPDK -c 0xe0 -n 1 --socket-mem=1024,0 --file-prefix flowmown --no-pci --vdev 'net_virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user-2'
      
