#!/bin/bash

sudo mkdir -p /tmp/bess
sudo rm /tmp/bess/* 2> /dev/null

sudo /home/tianzhu/bess/bessctl/bessctl daemon start

while [[ "$?" -ne 0 ]]
do
	echo "startup failure, trying it again!"
	sudo /home/tianzhu/bess/bessctl/bessctl daemon start
done

echo "bess daemon started!"

if [[ -z "${1}" ]]
then
	config="p2p"
else
	config="#{1}"
fi

echo "configuration: ${config}"

sudo /home/tianzhu/bess/bessctl/bessctl run file "${config}.bess"
