#!/bin/bash

export VHOST_SOCK_DIR=/tmp/fastclick

sudo docker run -it --name=moongen-fastclick-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/fastclick -v /lib/modules/$(uname -r):/lib/modules/$(uname -r) -v  /dev:/dev --privileged moongen
