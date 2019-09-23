# netmap/VALE tests
* Installation instructions are detailed in https://github.com/luigirizzo/netmap. Install it from the source and build the related tools including `VALE switch`, `pkt-gen`, and `bridge` etc.
* Build netmap's customized version of QEMU to support ptnet mechanism. More details can be found [here](https://github.com/luigirizzo/netmap/blob/master/README.ptnetmap.md). All the virtual machines mentioned here are based on this special version of QEMU.  
* Bind concerning physical ports to netmap's `ixgbe` device driver.
* Enable promiscuous mode for the physical ports:

  **sudo ip link set [interface name] promisc on**

## p2p test
### Steps:
* Start an instance of VALE switch named `vale0` and attach two physical interfaces to it:

  **sudo vale-ctl -b vale0:if0**
  
  **sudo vale-ctl -b vale0:if1**

  The interface names `if0` and `if1` need to be modifed to the correct name on your server, the names can be verified through the `ifconfig/ip` commands or DPDK's `dpdk-devbind.py -s` command (just check the `if` field).
  
* Instantiate MoonGen to perform throughput (unidirectional/bidirectional) and latency tests:
    * Go to the MoonGen repo directory:
    
      **cd ../moongen/**
      
    * For unidirectional test: 
    
      **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      
    * For bidirectional test: 
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
      
    * For latency test: 
    
      **sudo ./latency-test.sh -r [packet rate (Mbps)]**
      
      Vary the packet rate as detailed [here](https://github.com/ztz1989/software-switches/tree/artifacts/moongen#latency-test).
    
## p2v test
### Steps:
* Start an instance of VALE, attach a physical port and a `ptnet` port to it and then instantiate the virtual machine using QEMU/KVM with a ptnet-pci virtual interface. The following script does all the work:

  **./p2v.sh**
  
* For unidirectional throughput test:
    * Inside the VM, start an pkt-gen instance to receive packets from the `ptnet` interface.
    
      **pkt-gen -i vif0 -f rx**
      
      Note that `vif0` is the name assigned to the ptnet virtual interface, it may vary depending on systems. Please adjust it accordingly.
      
    * On the host side, go to our moongen directory and start its unidirectional test script:
    
      **cd ../moongen/; sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
      
* For bidirectional throughput test:
    * Inside the VM, create a VALE interface `v0`: 
    
      **vale-ctl -n v0**
      
    * attach both vif0 and v0 to VALE (named `vale1` here):
    
      **vale-ctl -a vale1:vif0** 
      
      Note again that vif0 is the name assigned to the ptnet virtual interface, it may vary on different systems.

      **vale-ctl -a vale1:v0**
      
    * Then instantiate a pair of pkt-gen TX/RX threads: 
    
      **pkt-gen -i vale1:v0 -f tx**
      
      **pkt-gen -i vale1:v0 -f rx**
      
    * On the host side, go to the moongen directory of this repo and run the bidirectional test script:
    
      **cd ../moongen/; sudo ./bidirectional-test.sh -s [packet size (Bytes)]**

## v2v test
### Steps for throughput test:
* Start netmap and configure the cross-connect rules between two virtual ports using VALE switch, and start two QEMU/KVM 
virtual machines:

  * start VM1: **./v2v1.sh**

  * start VM2: **./v2v.sh**

* On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
    * For unidirectional test, start a pkt-gen TX thread to inject packets towards the other VM: 
    
      **pkt-gen -i vif0 -f tx**
    * For bidirectional test, create a VALE interface: 
    
      **vale-ctl -n v0**
     * attach both vif0 and v0:
    
       **vale-ctl -a vale1:vif0**
       
       vif0 is the name assigned to the ptnet virtual interface, it may vary depending on systems.
      
       **vale-ctl -a vale1:v0**
     * Then instantiate a pair of pkt-gen TX/RX thread:
    
       **pkt-gen -i vale1:v0 -f tx**
      
       **pkt-gen -i vale1:v0 -f rx**
       
* On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030):
    * For unidirectional test, start a pkt-gen RX thread to monitor traffic from the first VM: 
    
      **pkt-gen -i vif0 -f rx**
    * For bidirectional test, follow exactly the same configuration steps as the first VM:
    
      **vale-ctl -n v0**
      
      **vale-ctl -a vale1:vif0**
      
      **vale-ctl -a vale1:v0**
      
      **pkt-gen -i vale1:v0 -f tx**
      
      **pkt-gen -i vale1:v0 -f rx**

### For latency test
* Start netmap and configure the cross-connect rules between two virtual ports using VALE switch, and start two QEMU/KVM 
virtual machines:

  * Start VM1: **./v2v1.sh**

    Assign an IP address to the `vif0` virtio interface:
    
    **ip addr add 10.0.0.1 dev vif0**
    
    **ip link set vif0 up**
    
    **ip link set vif0 promisc on **
    
  * Start VM2: **./v2v.sh**
  
    Assign an IP address to the `vif0` virtio interface:
    
    **ip addr add 10.0.0.2 dev vif0**
    
    **ip link set vif0 up**
    
    **ip link set vif0 promisc on **
    
  * From VM1, ping 10.0.0.2 to measure the RTT:
  
    **ping 10.0.0.2 -i 0.000001**
    
    Here we issue 1 million packets per second, making the packet transmission rate the same as the timestamps-software.lua script.
  
## Loopback
### 1-VNF experiment:
  1. start netmap and configure multiple instances of VALE switch to realize the loopback forwarding workflow:
  
     **./loopback.sh**
     
  2. inside the VM, bind the two virtual interfaces to another VALE instance:
  
     **vale-ctl -a vale0:vif0**
     
     **vale-ctl -a vale0:vif1**
     
      * run MoonGen scripts on the host machine from NUMA node 1
       * Go to MoonGen directory of our repo:
       
         **cd ../moongen/**
         
       * unidirectional test: 
        
         **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
          
       * bidirectional test:
        
         **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
* From a terminal, configure netmap 2-VNF forwarding and launch the first VM: 
  
  **./loopback-2-vm.sh**
  
* open a terminal and launch the second VM: 

  **./loopback-2-vm1.sh**
  
  Each VM contains two virtual interfaces.
  
* Inside both VMs, use VALE switch to bridge the pair of virtual interfaces:
  
  **sudo vale-ctl -b vale0:vif0**
  
  **sudo vale-ctl -b vale0:vif1**
  
* Launch MoonGen for different kinds of measurements:
   * Go to MoonGen directory of our repo:
      
     **cd ../moongen/**
     
   * unidirectional test: 
   
     **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
     
   * bidirectional test: 
   
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
      
   * For latency test: 
   
      **sudo ./latency-test.sh -r [packet rate (Mbps)]**

## Detach all the physical/virtual ports from any VALE instance upon finishing, so as to avoid potential race conditions:
   **./detach.sh**
   
   VALE will keep grabing the interfaces if they are not detached from it.
