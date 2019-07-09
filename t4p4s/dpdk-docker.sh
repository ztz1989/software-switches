#!/bin/bash

export VHOST_SOCK_DIR=/tmp/t4p4s

sudo mkdir -p "${VHOST_SOCK_DIR}"
sudo rm "${VHOST_SOCK_DIR}/*" 2> /dev/null

if [[ -z "${1}" ]]
then
	NAME="t4p4s-testpmd-docker"
else
	NAME="${1}"
fi

sudo docker run -it --name="${NAME}" -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/t4p4s --privileged dpdk-18.11
