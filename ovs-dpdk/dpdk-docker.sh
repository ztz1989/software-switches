#!/bin/bash

export VHOST_SOCK_DIR=/usr/local/var/run/openvswitch

sudo mkdir -p "${VHOST_SOCK_DIR}"
sudo rm "${VHOST_SOCK_DIR}/*" 2> /dev/null

if [[ -z "${1}" ]]
then
	NAME="ovs-testpmd-docker"
else
	NAME="${1}"
fi

sudo docker run -it --name="${NAME}" -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/var/run/openvswitch --privileged dpdk-18.11
