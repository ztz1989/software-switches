# netmap/VALE experiments
* Installation instructions are detailed in https://github.com/luigirizzo/netmap. Install it from the source and build the related tools including `VALE switch`, `pkt-gen`, and `bridge` etc.
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
    
## p2v test
### Steps:
* Start netmap, bind a physical port and a ptnet port to it, configure forwarding rules between them, 
and instantiate virtual machine using QEMU/KVM and attach one virtual interface: ./p2v.sh
* For unidirectional test:
    * Inside the VM, start an pkt-gen instance to receive packets from the host
      **pkt-gen -i vif0 -f rx** # vif0 is the name assigned to the ptnet virtual interface, it may vary depending on systems.
    * On the host side, go to MoonGen repo directory and start its unidirectional test script on NUMA node 1:
    
      **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
* For bidirectional test:
    * Inside the VM, create a VALE interface: 
    
      **vale-ctl -n v0**
    * attach both vif0 and v0:
    
      **vale-ctl -a vale1:vif0** # vif0 is the name assigned to the ptnet virtual interface, it may vary depending on systems.

      **vale-ctl -a vale1:v0**
    * Then instantiate a pair of pkt-gen TX/RX thread: 
    
      **pkt-gen -i vale1:v0 -f tx**
      
      **pkt-gen -i vale1:v0 -f rx**
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1:
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**

## v2v test
### Steps:
* Start netmap and configure rules cross-connect rules between two virtual ports using VALE switch, and start two QEMU/KVM 
virtual machines:

  **./v2v1.sh**  # start VM1 which transmits packets to VM2
  
  **./v2v.sh**   # start VM2 which receives packet from VM1 and measures the throughput under unidirectional test
* On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
    * For unidirectional test, start a pkt-gen TX thread to inject packets towards the other VM: 
    
      **pkt-gen -i vif0 -f tx**
    * For bidirectional test, create a VALE interface: 
    
      **vale-ctl -n v0**
    * attach both vif0 and v0:
    
      **vale-ctl -a vale1:vif0** # vif0 is the name assigned to the ptnet virtual interface, it may vary depending on systems.
      
      **vale-ctl -a vale1:v0**
    * Then instantiate a pair of pkt-gen TX/RX thread:
    
      **pkt-gen -i vale1:v0 -f tx**
      
      **pkt-gen -i vale1:v0 -f rx**
* On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030):
    * For unidirectional test, start a pkt-gen RX thread to monitor traffic from the first VM: 
    
      **pkt-gen -i vif0 -f rx**
    * For bidirectional test, follow exactly the same configuration steps as the first VM.
  
## Loopback
### 1-VNF experiment:
  1. start netmap and configure multiple instances of VALE switch to realize the loopback forwarding workflow:
  
     **./loopback.sh
  2. inside the VM, bind the two virtual interfaces to another VALE instance:
  
     **vale-ctl -a vale0:vif0**
     
     **vale-ctl -a vale0:vif1**
      * run MoonGen scripts on the host machine from NUMA node 1:
       * Go to MoonGen directory of our repo.
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
