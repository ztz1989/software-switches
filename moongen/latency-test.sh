#!/bin/bash

# This script is created to measure the throughput and latency of Software/Virtual switches

rate=${1}
size=${2}

CURR_DIR=$(pwd)

if [[ "${#}" -lt 2 ]]
then
	echo "Usage: ${0} TX_RATE PKT_SIZE"
	exit 1
fi

echo "Packet rate: ${1}, Packet size: ${2}"

MOONGEN_DIR="/home/tzhang/MoonGen/"


cd $MOONGEN_DIR
sudo ./build/MoonGen $CURR_DIR/latency-test.lua 0 1 -r "${rate}" -s "${size}"
