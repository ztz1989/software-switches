#!/bin/bash

export VHOST_SOCK_DIR=/tmp/fastclick

sudo docker run -it --name=fastclick-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/fastclick --privileged dpdk-docker
