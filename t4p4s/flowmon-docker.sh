#!/bin/bash

export VHOST_SOCK_DIR=/tmp/t4p4s

sudo docker run -it --name=t4p4s-flowmon-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/t4p4s --privileged flowmon-docker
