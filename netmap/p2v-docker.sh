#!/bin/bash

DOCKER_NAME="netmap-docker"

if [[ -z "${1}" ]]
then
	DOCKER_NAME="netmap-docker"
else
	DOCKER_NAME="${1}"
fi

pid=sudo docker inspect -f '{{.State.Pid}}' ${DOCKER_NAME}
echo "Curent process ID: " ${pid}

sudo mkdir -p /var/run/netns/
sudo rm /var/run/netns/* 2> /dev/null
sudo ip link delete veth1 2> /dev/null
sudo ip link delete veth2 2> /dev/null

sudo ln -s /proc/$pid/ns/net /var/run/netns/${DOCKER_NAME}

sudo ip link add veth1 type veth peer name veth2
sudo ip link set veth2 netns ${DOCKER_NAME}

sudo ip link set veth1 up
sudo ip link set veth2 up
