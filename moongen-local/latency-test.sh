#!/bin/bash

# This script is created to measure the throughput and latency of Software/Virtual switches

rate=${1}
size=${2}

if [[ "${#}" -lt 2 ]]
then
	echo 'Usage: ${0} TX_RATE PKT_SIZE'
	exit 1
fi

echo "Packet rate: ${1}, Packet size: ${2}"

cd $MOONGEN_DIR

sudo ./build/MoonGen examples/l3-load-latency.lua 0 1 -r "${rate}" -s "${size}"
