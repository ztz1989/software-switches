#!/bin/bash

export VHOST_SOCK_DIR=/tmp/bess

sudo docker run -it --name=flowmon-bess -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/bess --privileged flowmon-docker
