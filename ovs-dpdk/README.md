# Instructions to reproduce the OVS-DPDK experiments

## Experiments in physical environment (nic-nic communication)
The script "ovs-nic-nic.sh" initiates the DPDK, reserves memory on NUMA node 0, pins OVS-DPDK threads to specific cores and configures the rules to setup the direct communication between two physical NICs.

### Steps:
* Start OVS and configure rules: ./ovs-nic-nic.sh
* Inspect the throughput using MoonGen to TX and RX on NUMA node 1, instructions are detailed in [moongen-local section](https://github.com/ztz1989/software-switches/tree/master/moongen-local)
    * cd ../moongen-local
    * For unidirectional test: sudo ./throughput-test.sh
    * For bidirectional test: sudo ./bidirectional-test.sh
    * For latency test: sudo ./latency-test.sh
    
## Experiments in Virtual environment
This set of experiments include Physical <-> Virtual, Virtual <-> Virtual and Physical-Virtual-Physical scenarios.  

### Virtual machines
* Physical <-> Virtual test:
  1. Start OVS and configure forwarding rules
      * ./ovs-nic1-vm1.sh 
  2. Start virtual machine using QEMU/KVM and attach one virtual interface: ./nic1-vm1.sh
  3. Login to the VM
      * username: root
      * password: root
  4. Configure virtual machines: ./setup.sh (under /root directory).
  5. Login to the VM by opening new terminals and type: ssh root@localhost -p 10020. This can avoid the noisy logs of Centos.
  6. Start FlowMown-DPDK to monitor inside the VM:
      * cd /root/monitor/
      * ./build/FlowMown-DPDK -c 3
  7. Open a new terminal on the host machine and start MoonGen to TX packets from NIC 1:
      * cd ../moongen-local
      * sudo ./throughput-test.sh

* Virtual <-> Virtual test:
  1. Start OVS and configure the forwarding rules between two VMs
      * ./ovs-vm-vm.sh
  2. Start two VMs using QEMU/KVM:
      * ./vm-vm1.sh    # start VM1 which transmits packets to VM2
      * ./vm-vm.sh     # start VM2 which receives packet from VM1 and measures the throughput
  3. On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
      * ./setup.sh
      * cd /root/MoonGen
      * ./build/MoonGen example/l2-load-latency.lua 0 0
  4. On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030), we start an instance of FlowMown-DPDK to measure the inter-VM throughput:
      * ./setup.sh
      * cd /root/monitor
      * ./build/FlowMown -c 3
  
* Physical <-> Virtual <-> Physical test:
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
      
### Containers
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
