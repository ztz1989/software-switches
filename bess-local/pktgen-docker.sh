#!/bin/bash

export VHOST_SOCK_DIR=/tmp/bess

sudo docker run -it --name=pktgen-bess -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/bess --privileged pktgen-dpdk-pktgen-3.1.1
