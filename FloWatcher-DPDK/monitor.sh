#!/bin/bash

FLOWATCHER_DIR="/home/tianzhu/Docker-imgs/monitor/FlowMon-Docker"

cd "${FLOWATCHER_DIR}"
sudo ./build/FlowMon-DPDK -w 84:00.0 -l 14,15,16 --socket-mem=0,1024 --file-prefix=m2
