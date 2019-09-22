# BESS experiments
Install BESS according to the instructions on [BESS official website](https://github.com/NetSys/bess). We used the Hashwell tarball available [here](https://github.com/NetSys/bess/releases/download/v0.4.0/bess-haswell-linux.tar.gz).

## p2p test
### Steps:
* Start BESS and configure rules cross-connect rules between two physical ports:
    * Go to BESS installation directory.
    * Open a new ternimal, start BESS daemon process and configure p2p forwarding for BESS:
     * For unidirectional test: 
     
       **./start_bess.sh p2p**
     
       Then start MoonGen's unidirectional throughput test script on NUMA node 1:
       
       **cd path/to/MoonGen; sudo ./unidirectional-test.sh -s [packet size (Bytes)]**
     * For bidirectioanl test: 
     
       **./start_bess.sh p2p-bi**

       Then start MoonGen's bidirectional throughput test script on NUMA node 1:
       
       **cd path/to/MoonGen; sudo ./bidirectional-test.sh  -s [packet size (Bytes)]**
     * For latency test:
     
       **./start_bess.sh p2p**
       
       Then start MoonGen's bidirectional latency test script on NUMA node 1:

       **cd path/to/MoonGen; sudo ./latency-test.sh -r [packet rate (Mpps)]**
       
       As detailed [here](https://github.com/ztz1989/software-switches/blob/artifacts/moongen/README.md#latency-test), we vary packet rate to collect latency statistics. 
    
## p2v test
### Steps:
* Start BESS and configure rules cross-connect rules between two physical ports:
    * Go to BESS installation directory and launch BESS CLI: sudo ${BESS_DIR}/bessctl/bessctl
    * On the CLI, start BESS daemon process: daemon start
    * Run Configure p2v forwarding for BESS on the CLI:
     * For unidirectional test: run file p2v.bess
     * For bidirectioanl test: run file p2v-bi.bess
* Start virtual machine using QEMU/KVM and attach one virtual interface: ./p2v.sh
* Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
* For unidirectional test:
    * Inside the VM, to to FloWatcher-DPDK directory and instantiate FloWatcher-DPDK to measure unidrectional throughput:  
    
      **./build/FloWatcher-DPDK -c 3**
    * On the host side, go to MoonGen repo directory and start its unidirectional test script on NUMA node 1: sudo 
    
      **./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]**
* For bidirectional test:
    * Inside the VM, go to MoonGen directory: **cd /root/MoonGen**
    * Execute the MoonGen TX/RX script: 
    
      **./build/MoonGen ../script/txrx.lua -r [packet rate (Mpps)] -s [packet size (Bytes)]**
    * On the host side, run MoonGen bidirectional test scripts on NUMA node 1: 
    
      **sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]**

## v2v test
### Steps:
* Start BESS and configure rules cross-connect rules between two physical ports:
    * Go to BESS installation directory and launch BESS CLI: sudo ${BESS_DIR}/bessctl/bessctl
    * On the CLI, start BESS daemon process: daemon start
    * Run Configure v2v forwarding for BESS on the CLI:
     * For unidirectional test: run file v2v.bess
     * For bidirectioanl test: run file v2v-bi.bess
* Start two QEMU/KVM virtual machines:
    * **./v2v1.sh**    # start VM1 which transmits packets to VM2
    * **./v2v.sh**     # start VM2 which receives packet from VM1 and measures the throughput
* On VM1 (which can also be logged in from the host machine using: ssh root@localhost -p 10020), we start MoonGen using the following commands:
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to MoonGen directory and run its l2-load-latency sample application: 
    
      **./build/MoonGen example/l2-load-latency.lua 0 0**
* On VM2 (which can also be logged in from the host machine using: ssh root@localhost -p 10030), we start an instance of FloWatcher-DPDK to measure the inter-VM throughput:
    * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
    * Go to FloWatcher-DPDK installation directory and launch it using: **./build/FloWatcher-DPDK -c 3**
  
## Loopback
### 1-VNF experiment:
  1. Start BESS and configure rules cross-connect rules between two physical ports:
    * Go to BESS installation directory and launch BESS CLI: sudo ${BESS_DIR}/bessctl/bessctl
    * On the CLI, start BESS daemon process: daemon start
    * Run Configure p2p forwarding for BESS on the CLI:
      * For unidirectional test: run file loopback.bess
      * For bidirectioanl test: run file loopback-bi.bess
  2. Start an instance of VM and attach it with two virtual interfaces
      * ./loopback.sh
  3. Inside the VM, initiate DPDK and run the DPDK l2fwd sample application
      * Login to the VM and setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows.
      * Go to DPDK l2fwd sample application directory and launch it: **./build/l2fwd -l 0-3 -- -p 3 -T 1 -q 1**
      * run MoonGen scripts on the host machine from NUMA node 1:
       * Go to MoonGen directory of our repo.
       * unidirectional test: **sudo ./unidirectional-test.sh**
       * bidirectional test: **sudo ./bidirectional-test.sh**
     
### Multi-VNF experiments:
Depending on the number of VNFs, our experiments use different scripts. We demonstrate only 2-VNF experiment as an example:
1. Start BESS and configure rules cross-connect rules between two physical ports:
    * Go to BESS installation directory and launch BESS CLI: sudo ${BESS_DIR}/bessctl/bessctl
    * On the CLI, start BESS daemon process: daemon start
    * Run Configure p2p forwarding for BESS on the CLI:
      * For unidirectional test: run file loopback-2-vm.bess
      * For bidirectioanl test: run file loopback-2-vm-bi.bess
2. Open a new terminal and launch the first VM: ./loopback-vm1.sh
3. Open another terminal and launch the second VM: ./loopback-vm2.sh
4. Inside both VMs, setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows and launch DPDK l2fwd sample application.
5. Launch MoonGen for different measurement:
   * Go to MoonGen directory of our repo.
   * unidirectional test: **sudo ./unidirectional-test.sh**
   * bidirectional test: **sudo ./bidirectional-test.sh**
   * For latency test: 
   
     **sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]**

