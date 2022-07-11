#!/bin/bash

# script to start fastClick on NUMA node 0 with 2 NICs

sudo mkdir -p /tmp/fastclick
sudo rm -rf /tmp/fastclick/*

FASTCLICK_DIR="/home/tzhang/fastclick"

if [[ -z "${1}" ]]
then
	config="loopback.click"
else
	config="${1}"
fi

sudo "${FASTCLICK_DIR}"/bin/click --dpdk -l 1-2 \
		 -w 04:00.0 -w 04:00.1 \
		 --vdev=eth_vhost0,iface=/tmp/fastclick/vhost-user-0 \
		 --vdev=eth_vhost1,iface=/tmp/fastclick/vhost-user-1 \
		 --socket-mem=2048,0 -- "${config}"
