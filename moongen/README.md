# MoonGen scripts for our experiments
MooGen is a high-performance software traffic generator (or processor). Our experiments heavily rely on its various functionalities. Note that all the scripts used in our experiments are based on MoonGen's example scripts, for a more detailed view, please check [here](https://github.com/emmericp/MoonGen/tree/master/examples).  

## Installation
Detailed instructions of MoonGen can be found on MoonGen webside: https://github.com/emmericp/MoonGen. The version we used was commit 31af6e6. Since we only explored the basic features of MoonGen, newer versions are expected to work as well.

## Tests performed using MoonGen
Our experiments wrap MoonGen scripts for both throughput and latency tests. As MoonGen is based on DPDK, there are several critical parameters that need to be supplied before running experiments. The basic DPDK configuration of MoonGen is specified through the **dpdk-conf.lua** file. The most important parameter is pciWhitelist option, which is equivalent to DPDK's EAL -w/--pci-whitelist option. Our experiments only requires two interfaces specified in the list. It is necessary to adjust it with list of PCI addresses of physical/virtual ports on your own server. Other options such as cores, socket memories, and file prefix (for multiple processes) can be adjusted as well.
MoonGen should be deployed differently for different test scenarios: For p2p and loopback tests, MoonGen is deployed on NUMA node 1; For p2v and v2v tests, MoonGen is deployed inside virtual machine(s) on NUMA node 0.

### Throughput test
* Unidirectional test:

  **sudo ./unidirectional-test.sh [-s packet size]**

  Note that variable ${MOONGEN_DIR} needs to be modifed to the local MoonGen installation directory on the host. By executing this script, MoonGen calls the throughput-test.lua script to perform undirectional throughput test. It transmits packets through the first port on the whitelist. The generated packets (ethernet frames) are then forwarded to the software switch (SUT) on NUMA node 0. Then MoonGen collects throughput features from the second port on the whitelist. 
  
* Bidirectional test: 

  **sudo ./bidirectional-test.sh [-s packet size]**
  
  Similar to unidirectional test, the ${MOONGEN_DIR} variable needs to be customized according to the installation directory of MoonGen on your local server. This script instructs MoonGen to transmit/measure traffic (ethernet frames) at both interfaces simultaneously. 

Both scripts will output the average throughput upon termination. Also note that the packet TX rate can also be changed by appending "-r [rate in Mbps]" option, our experiments stick to 10Gbps. 

### Latency test
Script for latency test is very simialr to the **unidirectional-test.sh** script. The only difference is this script generates UDP/PTP packets instead of simple ethernet frames. 

**sudo ./latency-test.sh [-r packet rate]**

Note that we only used 64B packets in our experiments and varied the packet rate among [0.1, 0.5, 0.99] of the maximal sustainable throughput. In particular, we firstly transmit at 10Gbps rate to obtain the maximal sustainable throughput R+. Then we repeat the same experiments with [0.1, 0.5, 0.99] of R+ respectively.
By default, MoonGen will output the results in the "histogram.csv" file in current directory.
