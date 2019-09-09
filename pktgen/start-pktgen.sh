#!/bin/bash

PKTGEN_DIR="/home/tianzhu/pktgen-dpdk"

cd "${PKTGEN_DIR}"
sudo ./app/x86_64-native-linuxapp-gcc/app/pktgen -l 12-16 --socket-mem=0,1024 -w 84:00.0 --file-prefix=m2 -- -P -m "[13:15].0" -T
