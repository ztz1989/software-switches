#!/bin/bash

SNABB_DIR="/home/tianzhu/snabb"

sudo mkdir -p "/tmp/snabb"

if [[ -z "${1}" ]]
then
	config="p2p"
else
	config="${1}"
fi

echo "APP ${config}"
cd $SNABB_DIR

sudo taskset -c 10-11 src/snabb ${config} 0000:0b:00.0 0000:0b:00.1
