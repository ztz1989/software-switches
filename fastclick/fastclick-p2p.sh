#!/bin/bash

# script to start fastClick on NUMA node 0 with 2 NICs

FASTCLICK_DIR="/home/tzhang/fastclick"

if [[ -z "${1}" ]]
then
	config="unidirectional-x.click"
else
	config="${1}"
fi

sudo ${FASTCLICK_DIR}/bin/click --dpdk -l 1 -w "0000:04:00.0" -w "0000:04:00.1" --socket-mem=16,0 -- "${config}"
