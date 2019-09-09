#!/bin/bash

export VHOST_SOCK_DIR=/tmp/snabb

if [[ -z "${1}" ]]
then
	NAME='snabb-pktgen-docker'
else
	NAME="${1}"
fi

sudo docker run -it --name="${NAME}" -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/snabb -v /var/run/snabb/hugetlbfs/:/var/run/snabb/hugetlbfs/ --privileged pktgen-3.1.1
