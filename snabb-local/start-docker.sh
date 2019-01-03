#!/bin/bash

export VHOST_SOCK_DIR=/tmp/snabb

sudo docker run -it --name=ovs-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/var/run/openvswitch --privileged dpdk-docker
