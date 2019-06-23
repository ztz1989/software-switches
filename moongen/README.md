# MoonGen scripts for our experiments
MooGen is a high-performance software traffic generator (or processor). Our experiments heavily rely on its various functionalities. 

## Installation
Detailed instructions of MoonGen can be found on MoonGen webside: https://github.com/emmericp/MoonGen.

## Throughput test
Our experiments wrap MoonGen scripts for both throughput and latency tests.

* Unidirectional test: sudo ./unidirectional-test.sh [-s packet size] [-r packet rate]

* Bidirectional test: sudo ./bidirectional-test.sh [-s packet size] [-r packet rate]

## Latency test
sudo ./latency-test.sh [-s packet size] [-r packet rate] [-s packet size]
