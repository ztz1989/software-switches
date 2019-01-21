# Instructions to reproduce the OVS-DPDK experiments

## Experiments in physical environment (nic-nic communication)
The script "ovs-nic-nic.sh" initiates the DPDK, reserves memory on NUMA node 0, pins OVS-DPDK threads to specific cores and configures the rules to setup the direct communication between two physical NICs.

### Steps to reproduce:
* Start OVS and configure rules: ./ovs-nic-nic.sh
* Inspect the throughput using MoonGen to TX and RX on NUMA node 1, instructions are detailed in 

## Experiments in Virtual environment
This set of experiments include Physical <-> Virtual, Virtual <-> Virtual and Physical-Virtual-Physical scenarios.  

### Virtual machines
* Physical <-> Virtual:
  1. Start OVS and configure forwarding rules: ./ovs-nic1-vm1.sh 
  2. Start virtual machine using QEMU/KVM and attach one virtual interface: ./nic1-vm1.sh
  3. Login to the VM
      * username: root
      * password: root
  4. Configure virtual machines: ./setup.sh (under /root directory).
  5. Login to the VM by opening new terminals and type: ssh root@localhost -p 10020. This can avoid the noisy logs of Centos.
  6. Start FlowMown-DPDK to monitor inside the VM:
      * cd monitor/
      * ./build/FlowMon-DPDK -c 3
  7. Open a new terminal on the host machine and start MoonGen to TX packets from NIC 1:
      * cd ../moongen-local
      * sudo ./throughput-test.sh
  
### Containers

