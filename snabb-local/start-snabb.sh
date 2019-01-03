#!/bin/bash

SNABB_DIR="/home/tianzhu/snabb"

if [[ -z "${1}" ]]
then
	config="l2fwd"
else
	config="${1}"
fi

echo "APP ${config}"
cd $SNABB_DIR

sudo numactl --membind=0 taskset -c 9-11 src/snabb ${config} 0000:0b:00.0 0000:0b:00.1
