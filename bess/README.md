# BESS experiments
Install BESS according to the instructions on [BESS official website](https://github.com/NetSys/bess). We used the Hashwell tarball available [here](https://github.com/NetSys/bess/releases/download/v0.4.0/bess-haswell-linux.tar.gz).

## p2p test
### Steps:
* Start BESS and configure rules cross-connect rules between two physical ports:
    * Go to BESS installation directory.
    * Open a new ternimal, start BESS daemon process and configure p2p forwarding for BESS:
     * For unidirectional throughput test: 
     
       **./start_bess.sh p2p**
     
       Then start MoonGen's unidirectional throughput test script on NUMA node 1:
       
       **cd ../moongen; sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
     * For bidirectioanl throughput test: 
     
       **./start_bess.sh p2p-bi**

       Then start MoonGen's bidirectional throughput test script on NUMA node 1:
       
       **cd ../moongen; sudo ./bidirectional-test.sh  -s [packet size (Bytes)]**
     * For latency test:
     
       **./start_bess.sh p2p**
       
       Then start MoonGen's bidirectional latency test script on NUMA node 1:

       **cd ../moongen; sudo ./latency-test.sh -r [packet rate (Mbps)]**
       
       As detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/moongen/README.md#latency-test), we vary packet rate to collect latency statistics. 

## p2v test
### Steps:
* Start BESS and configure rules cross-connect rules between the pair of physical and virtual ports:
    * Open a new termial, go to BESS installation directory and configure p2v forwarding for BESS:
     * For unidirectional throughput test: 
     
       **./start_bess.sh p2v**
     
     * For bidirectional throughput test:
     
       **./start_bess.sh p2v-bi**
     
* Start a virtual machine using QEMU/KVM and attach one virtual interface by executing **./p2v.sh**
* Inside the VM, setup DPDK and other test tools as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
* For unidirectional test:
    * Inside the VM, to to FloWatcher-DPDK directory and instantiate FloWatcher-DPDK to measure unidrectional throughput:  
    
      **cd path/to/FloWatcher-DPDK; ./build/FloWatcher-DPDK -c portmask**
      
    * On the host side, go to MoonGen repo directory and start its unidirectional test script on NUMA node 1: sudo 
    
      **cd ../moongen; ./unidirectional-test.sh -s [packet size (Bytes)]**
      
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: **cd /root/MoonGen**
    * Execute the MoonGen TX/RX script: 
    
      **./build/MoonGen ../script/txrx.lua -s [packet size (Bytes)]**
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: 
    
      **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**

## v2v test
### Steps:
* Open a new terminal, start BESS and configure v2v forwarding for BESS:
     * For unidirectional test: **./start_bess.sh v2v**
     * For bidirectioanl test: **./start_bess v2v-bi**
     * For latency test: **./start_bess v2v-latency**
* Start two QEMU/KVM virtual machines:
    * Open a terminal and start VM1: **./v2v1.sh**    
    * Open another terminal and launch VM2: **./v2v.sh**
* On VM1, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
    * For both throughput test, go to MoonGen directory and run the txrx.lua script:
    
      **cd path/to/MoonGen; ./build/MoonGen path/to/txrx.lua 0 0**
      
      The txrx.lua script is also modified from MoonGen's l2-load-latency.lua sample script. Instead of using two ports, it just TX/RX on the same port simultaneously.
    
    * For latency test, ****
      
* On VM2, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md).
    * For unidrectional throughput test, go to FloWatcher-DPDK installation directory and launch it using: 
    
      **cd path/to/FloWatcher-DPDK; ./build/FloWatcher-DPDK -c 3**
      
    * For bidirectional throughput test, go to MoonGen directory and run the txrx.lua script:
    
      **cd path/to/MoonGen; ./build/MoonGen path/to/txrx.lua 0 0**
      
    * For latency test, launch DPDK l2fwd sample app to forward packets between the two virtual interfaces of VM2.
    
      **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
  
## Loopback
### 1-VNF experiment:
  1. Open a terminal, start BESS and configure the corresponding forwarding for BESS as follows: 
      * For unidirectional throughput test: **./start_bess.sh loopback**
      * For bidirectioanl throughput test: **./start_bess.sh loopback-bi**
  2. Start an instance of VM and attach it with two virtual interfaces by executing the **loopback.sh** script.
  3. Inside the VM, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md). 
  4. Go to DPDK l2fwd sample application directory and launch it:
      
        **cd path/to/l2fwd; ./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
      * run MoonGen scripts on the host machine from NUMA node 1:
       * Go to MoonGen directory of our repo: **cd ../moongen**
       * unidirectional test: **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
       * bidirectional test: **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
       * For latency test: **sudo ./latency-test.sh -r [packet rate (Mbps)]**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
1. Open a new terminal, start BESS and configure the corresponding forwarding for BESS:
     * For unidirectional test: **./start_bess.sh loopback-2-vm**
     * For bidirectioanl test: **./start_bess.sh loopback-2-vm-bi**
2. Open a new terminal and launch the first VM: **./loopback-vm1.sh**
3. Open another terminal and launch the second VM: **./loopback-vm2.sh**

Each VM contains two virtio virtual interfaces.
4. Inside both VMs, setup DPDK as detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md) and launch DPDK l2fwd sample application.
5. Launch MoonGen to measure different metrics:
   * Go to MoonGen directory of our repo.
   * unidirectional test: **sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
   * bidirectional test: **sudo ./bidirectional-test.sh -s [packet size (Bytes)]**
   * For latency test: 
     **sudo ./latency-test.sh -r [packet rate (Mbps)]**

