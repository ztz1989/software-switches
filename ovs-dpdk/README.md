# OVS-DPDK experiments

## p2p test
### Steps:
* Start OVS and configure rules cross-connect rules between two physical ports: ./ovs-p2p.sh
    * Current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify it to your respective PCI addresses for reproduction.
* Instantiate MoonGen to TX/RX the performance for throughput (unidirectional/bidirectional) and latency:
    * Go to the MoonGen repo directory
    * For unidirectional test: sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For bidirectional test: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For latency test: sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]
    
## p2v test
### Steps:
* Start OVS, bind a physical port and a vhost-user port to OVS-DPDK, then configure forwarding rules between them:
    * ./ovs-p2v.sh
* Start virtual machine using QEMU/KVM and attach one virtual interface: ./p2v.sh
* Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
* For unidirectional test:
    * Inside the VM, to to FloWatcher-DPDK directory and instantiate FloWatcher-DPDK to measure unidrectional throughput: ./build/FloWatcher-DPDK -c 3
    * On the host side, go to MoonGen repo directory and start its unidirectional test script on NUMA node 1: sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: cd /root/MoonGen
    * Execute the MoonGen TX/RX script: ./build/MoonGen ../script/txrx.lua -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]

## v2v test
### Steps:
* Start OVS and configure the forwarding rules between two VMs
    * ./ovs-v2v.sh
* Start two QEMU/KVM virtual machines:
    * ./v2v1.sh    # start VM1 which transmits packets to VM2
    * ./v2v.sh     # start VM2 which receives packet from VM1 and measures the throughput
* On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to MoonGen directory and run its l2-load-latency sample application: /build/MoonGen example/l2-load-latency.lua 0 0
* On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030), we start an instance of FloWatcher-DPDK to measure the inter-VM throughput:
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to FloWatcher-DPDK installation directory and launch it using: ./build/FloWatcher-DPDK -c 3
  
## Loopback
### 1-VNF experiment:
1. start OVS and configure the loopback forwarding rules
      * ./ovs-loopback.sh
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
1, start OVS 2-VNF configuration script: ./ovs-loopback-2-vm.sh
2, open a new terminal and launch the first VM: ./loopback-vm1.sh
3, open another terminal and launch the second VM: ./loopback-vm2.sh
4, inside both VMs, setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows and launch DPDK l2fwd sample application.
5, Launch MoonGen for throughput measurement:
       * Go to MoonGen directory of our repo.
       * unidirectional test: sudo ./unidirectional-test.sh 
       * bidirectional test: sudo ./bidirectional-test.sh

## Containers (To be completed)
* Physical <-> Virtual test
   * start OVS and configure forwarding rules
      * ./ovs-nic1-vm1.sh
   * start an instance of FlowMown-DPDK container and login
      * ./flowmown-docker.sh
   * start FlowMown-DPDK inside the container
      * ./build/FlowMown-DPDK -c 0xe0 -n 1 --socket-mem=1024,0 --file-prefix flowmown --no-pci --vdev 'net_virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user-2'

# Clear the flow table and terminate all OVS threads
  * ./terminate_ovs-dpdk.sh
 
 This script terminates both ovs daemon and ovsdb threads. This step is necessary before running any experiment for other software switches, just in case of race conditions on physical/virtual interfaces.
