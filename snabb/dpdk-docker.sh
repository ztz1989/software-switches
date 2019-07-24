#!/bin/bash

export VHOST_SOCK_DIR=/tmp/snabb

#sudo mkdir -p "${VHOST_SOCK_DIR}"
#sudo rm "${VHOST_SOCK_DIR}/*" 2> /dev/null

if [[ -z "${1}" ]]
then
	NAME="snabb-testpmd-docker"
else
	NAME="${1}"
fi

sudo docker run -it --name="${NAME}" -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/snabb --privileged dpdk-18.11
