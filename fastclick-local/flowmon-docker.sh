#!/bin/bash

export VHOST_SOCK_DIR=/tmp/fastclick

sudo docker run -it --name=flowmon-docker-fastclick -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/fastclick --privileged flowmon-docker
