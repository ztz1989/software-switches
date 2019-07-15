#!/bin/bash

if [[ -z "${1}" ]]
then
	NAME="netmap-docker"
else
	NAME="${1}"
fi

sudo docker run -it --name="${NAME}" --privileged netmap
