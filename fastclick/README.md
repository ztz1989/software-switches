# FastClick experiments

## p2p test
### Steps:
* Start FastClick and configure rules cross-connect rules between two physical ports: ./fastclick-p2p.sh
    * Current configuration designates the two ports with PCI address 0b:00.0 and 0b:00.1, modify it to your respective PCI addresses for reproduction.
    * For bidirectional test, Fastclick should be launched as: ./fastclick-p2p.sh bidirectional-x.click
* Instantiate MoonGen to TX/RX the performance for throughput (unidirectional/bidirectional) and latency:
    * Go to the MoonGen repo directory
    * For unidirectional test: sudo ./unidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For bidirectional test: sudo ./bidirectional-test.sh  -r [packet rate (Mpps)] -s [packet size (Bytes)]
    * For latency test: sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]
    
## p2v test
### Steps:
* Start FastClick, bind a physical port and a vhost-user port to FastClick, then configure forwarding rules between them:
    * For unidirectional test, use: ./fastclick-p2v.sh
    * For bidirectional test, use: ./fastclick-p2v.sh bidirectional-x.click
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
* Start FastClick and configure the forwarding rules between two VMs
    * For unidirectional test, use: ./fastclick-v2v.sh
    * For bidirectional test, use: ./fastclick-v2v.sh bidirectional-x.click
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
1. start FastClick and configure the loopback forwarding rules
    * For unidirectional test, use: ./fastclick-loopback.sh
    * For bidirectional test, use: ./fastclick-loopback.sh loopback-bi.click
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
1, start FastClick 2-VNF configuration script: 
   * For unidirectional test, use: ./fastclick-loopback-2-vm.sh
   * For bidirectional test, use: ./fastclick-loopback-2-vm.sh loopback-2-vm-bi.click
2, open a new terminal and launch the first VM: ./loopback-vm1.sh
3, open another terminal and launch the second VM: ./loopback-vm2.sh
4, inside both VMs, setup DPDK according to https://github.com/ztz1989/software-switches#configure-dpdk-inside-the-vm-an-example-is-given-as-follows and launch DPDK l2fwd sample application.
5, Launch MoonGen for different measurement:
   * Go to MoonGen directory of our repo.
   * unidirectional test: sudo ./unidirectional-test.sh 
   * bidirectional test: sudo ./bidirectional-test.sh
   * For latency test: sudo ./latency-test.sh -r [packet rate (Mpps)] -s [packet size (Bytes)]

