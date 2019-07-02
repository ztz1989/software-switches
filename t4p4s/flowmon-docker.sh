#!/bin/bash

export VHOST_SOCK_DIR=/tmp/t4p4s

sudo docker run -it --name=flowmon-docker-t4p4s -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/t4p4s --privileged flowmon-docker
