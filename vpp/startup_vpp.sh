#!/bin/bash

export T=path/to/vpp/build-root/install-vpp-native/vpp
config="p2p"

sudo mkdir -p /tmp/vpp
sudo rm /tmp/vpp/* 2>/dev/null

if [[ "$#" -eq 0 ]];then
	sudo $T/bin/vpp -c startup-p2p.conf
else
	config="${1}"
	sudo $T/bin/vpp -c startup-"${config}".conf
fi
