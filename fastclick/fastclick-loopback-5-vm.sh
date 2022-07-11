#!/bin/bash

# script to start fastClick on NUMA node 0 with 2 NICs

sudo mkdir -p /tmp/fastclick
sudo rm -rf /tmp/fastclick/*

FASTCLICK_DIR="/home/tzhang/fastclick"

if [[ -z "${1}" ]]
then
	config="loopback-5-vm.click"
else
	config="${1}"
fi

sudo "${FASTCLICK_DIR}"/bin/click --dpdk -l 1-4,20-21 \
		 -w 04:00.0 -w 04:00.1 \
		 --vdev=eth_vhost0,iface=/tmp/fastclick/vhost-user-0 \
		 --vdev=eth_vhost1,iface=/tmp/fastclick/vhost-user-1 \
		 --vdev=eth_vhost2,iface=/tmp/fastclick/vhost-user-2 \
		 --vdev=eth_vhost3,iface=/tmp/fastclick/vhost-user-3 \
	         --vdev=eth_vhost4,iface=/tmp/fastclick/vhost-user-4 \
		 --vdev=eth_vhost5,iface=/tmp/fastclick/vhost-user-5 \
		 --vdev=eth_vhost6,iface=/tmp/fastclick/vhost-user-6 \
		 --vdev=eth_vhost7,iface=/tmp/fastclick/vhost-user-7 \
        	 --vdev=eth_vhost8,iface=/tmp/fastclick/vhost-user-8 \
         	 --vdev=eth_vhost9,iface=/tmp/fastclick/vhost-user-9 \
		 --socket-mem=64,0 -- "${config}"
