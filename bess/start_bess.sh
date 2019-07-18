#!/bin/bash

sudo mkdir -p /tmp/bess
sudo rm /tmp/bess/*

sudo /home/tianzhu/bess/bessctl/bessctl daemon start

while [[ "$?" -ne 0 ]]
do
	echo "startup failure, trying it again!"
	sudo /home/tianzhu/bess/bessctl/bessctl daemon start
done

echo "bess daemon started!"

if [[ "${1}" -ne 0 ]]
then
	config="${1}"
else
	config="p2p"
fi

echo "configuration: ${config}"

sudo /home/tianzhu/bess/bessctl/bessctl run file "${config}.bess"
