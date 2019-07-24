#!/bin/bash

SNABB_DIR="/home/tianzhu/snabb"

sudo mkdir -p "/tmp/snabb"
sudo rm "/tmp/snabb/*" 2> /dev/null

if [[ -z "${1}" ]]
then
	config="p2p"
else
	config="${1}"
fi

echo "APP ${config}"
cd $SNABB_DIR/src

sudo numactl --membind=0 taskset -c 9-11 ./snabb ${config} -v 0000:0b:00.0 0000:0b:00.1
