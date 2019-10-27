#!/bin/bash

FLOWATCHER_DIR="/home/tianzhu/FloWatcher-DPDK/monitor/"
DURATION=60

cd "${FLOWATCHER_DIR}"

if [[ -z "${1}" ]]
then
	sudo ./build/FlowMon-DPDK -l 14,15,16 --socket-mem=0,1024 -w 84:00.0 --file-prefix=m2
else
	sudo timeout -s SIGINT "${DURATION}" ./build/FlowMon-DPDK -l 14,15,16 --socket-mem=0,1024 -w 84:00.0 --file-prefix=m2
fi
