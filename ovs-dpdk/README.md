# Instructions to reproduce the OVS-DPDK experiments

## p2p test
### Steps:
* Start OVS and configure rules cross-connect rules between two physical ports: ./ovs-p2p.sh
    * Current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify it to your respective PCI addresses for reproduction.
* Instantiate MoonGen to TX/RX the performance for throughput (unidirectional/bidirectional) and latency:
    * Go to MoonGen directory: cd ../moongen
    * For unidirectional test: sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For bidirectional test: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For latency test: sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]
    
## p2v test
### Steps:
* Start OVS, bind a physical port and a vhost-user port to OVS-DPDK, then configure forwarding rules between them:
    * ./ovs-p2v.sh
* Start virtual machine using QEMU/KVM and attach one virtual interface: ./p2v.sh
* Setup DPDK: /root/setup.sh
* Login to the VM
    * username: root
    * password: root
* Configure virtual machines: ./setup.sh (under /root directory).
* Login to the VM by opening new terminals and type: ssh root@localhost -p 10020. The username and password are the same. This can avoid the noise of system logs.
* For unidirectional test:
    * Inside the VM, to to FloWatcher-DPDK directory: cd /root/monitor/
    * Instantiate FloWatcher-DPDK to measure unidrectional throughput: ./build/FloWatcher-DPDK -c 3
    * On the host side, go to MoonGen directory and start its unidirectional test script on NUMA node 1: cd ../moongen & sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: cd /root/MoonGen
    * Execute the MoonGen TX/RX script: ./build/MoonGen ../script/txrx.lua -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]

## v2v test
### Steps:
* Start OVS and configure the forwarding rules between two VMs
      * ./ovs-vm-vm.sh
* Start two QEMU/KVM virtual machines:
      * ./v2v1.sh    # start VM1 which transmits packets to VM2
      * ./v2v.sh     # start VM2 which receives packet from VM1 and measures the throughput
  3. On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
      * ./setup.sh
      * cd /root/MoonGen
      * ./build/MoonGen example/l2-load-latency.lua 0 0
  4. On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030), we start an instance of FlowMown-DPDK to measure the inter-VM throughput:
      * ./setup.sh
      * cd /root/monitor
      * ./build/FlowMown -c 3
  
## Loopback
### Steps:
1. start OVS and configure the PVP forwarding rules
      * ./ovs-nic2-vm1.sh
  2. start an instance of VM and attach it with two virtual interfaces
      * ./nic2-vm1.sh
  3. inside the VM, initiate DPDK and run the DPDK l2fwd sample application
      * ./setup.sh
      * cd /root/dpdk-stable-17.11.4/examples/l2fwd/build
      * ./l2fwd -l 0-3 -- -p 3 -T 1 -q 1
      * run MoonGen scripts on the host machine from NUMA node 1
           * cd ../moongen-local
           * unidirectional test: sudo ./throughput-test.sh 
           * bidirectional test: sudo ./bidirectional-test.sh
      
### Containers (To be completed)
* Physical <-> Virtual test
   * start OVS and configure forwarding rules
      * ./ovs-nic1-vm1.sh
   * start an instance of FlowMown-DPDK container and login
      * ./flowmown-docker.sh
   * start FlowMown-DPDK inside the container
      * ./build/FlowMown-DPDK -c 0xe0 -n 1 --socket-mem=1024,0 --file-prefix flowmown --no-pci --vdev 'net_virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user-2'

### Clear the flow table and terminate all OVS threads
  * ./terminate_ovs-dpdk.sh
 
 This step is necessary before running experiments for other software switches, just in case of race conditions on physical NICS.
