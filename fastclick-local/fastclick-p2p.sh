#!/bin/bash

# script to start fastClick on NUMA node 0 with 2 NICs

FASTCLICK_DIR="/home/tianzhu/fastclick"

if [[ -z "${1}" ]]
then
	config="unidirectional-x.click"
else
	config="${1}"
fi

sudo ${FASTCLICK_DIR}/bin/click --dpdk -c 0x400 -w "0000:0b:00.0" -w "0000:0b:00.1" --socket-mem=2048,0 -- "${config}"
