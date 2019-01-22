# SnabbSwitch Experiments
Here we describe instructions to reporduce our experiments with SnabbSwitch. The source code as well as other details of Snabb can be found [here](https://github.com/snabbco/snabb).

## Experiments in physical environment (nic-nic communication)
We have already composed some modules into snabb, including **l2fwd** and **cross**. The **l2fwd** is used for unidirectional communication while **cross** is dedicated to bidirectional communication.

### unidirectional test and latency test
  * sudo ./start-snabb.sh 
### bidirectional test
  * sudo ./start-snabb.sh cross

## Experiments in physical environment
We composed four snabb modules for experiments with virtual environments.

### Virtual machines
  * Physical <-> Virtual
    * start VM using QEMU. It creates a virtual interface and make it operate in vhost-user *server* mode.
      * ./nic1-vm1.sh
    * start snabb. vm-single module creates a virtual interface in /tmp/snabb/ directory, binds another physical NIC and interconnects the two interfaces
      * ./start-snabb.sh vm-single
    * Inside the VM, we firstly setup DPDK and bind virtual interface. 
      * ./setup.sh
    * Start FlowMown-DPDK as traffic monitor
      * cd /root/monitor
      * ./build/FlowMown-DPDK -c 3
    
  * Virtual <-> Virtual
  
  * Physical <-> Virtual <-> Physical


### Containers
  * Physical <-> Virtual
  
  * Virtual <-> Virtual
  
  * Physical <-> Virtual <-> Physical
