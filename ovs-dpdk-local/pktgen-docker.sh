#!/bin/bash

export VHOST_SOCK_DIR=/usr/local/var/run/openvswitch

sudo docker run -it --name=pktgen-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/var/run/openvswitch --privileged pktgen-dpdk-pktgen-3.1.1
