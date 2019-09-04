#!/bin/bash

# script to start fastClick on NUMA node 0 with 2 NICs

sudo mkdir -p /tmp/clicknf
sudo rm -rf /tmp/clicknf/*

if [[ -z "${1}" ]]
then
	config="unidirectional-x.click"
else
	config="${1}"
fi

sudo ${CLICKNF_DIR}/bin/click --dpdk -c 0x800 -w "0000:0b:00.0" --vdev=eth_vhost0,iface=/tmp/clicknf/vhost-user-0 --socket-mem=2048,0 -- "${config}"
