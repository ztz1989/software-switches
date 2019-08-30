#!/bin/bash

if [[ -z "${1}" ]]
then
	NAME="netmap-docker"
else
	NAME="${1}"
fi

sudo docker run -it --cpuset-cpus=24-27 --name="${NAME}" --privileged netmap
