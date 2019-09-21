# MoonGen scripts for our experiments
MooGen is a high-performance software traffic generator (or processor). Our experiments heavily rely on its various functionalities. 

## Installation
Detailed instructions of MoonGen can be found on MoonGen webside: https://github.com/emmericp/MoonGen.

## Tests performed using MoonGen
Our experiments wrap MoonGen scripts for both throughput and latency tests. 
### Throughput test
* Unidirectional test:

  **sudo ./unidirectional-test.sh [-s packet size] [-r packet rate]**

  Note that variable ${MOONGEN_DIR} needs to be modifed to the local MoonGen installation directory on the host. By executing this script, MoonGen calls the throughput-test.lua script to perform undirectional throughput test. The basic configuration of MoonGen is specified through the dpdk-conf.lua file. 
  
* Bidirectional test: sudo ./bidirectional-test.sh [-s packet size] [-r packet rate]

### Latency test

**sudo ./latency-test.sh [-s packet size] [-r packet rate] [-s packet size]**
