#!/bin/bash

# This script is created to measure the throughput and latency of Software/Virtual switches

MOONGEN_DIR=/usr/local/src/MoonGen/
CURR_DIR=$(pwd)

# default values for packet rates [Mpps]
rate=10000

if [[ "${UID}" -ne 0 ]]
then
	echo "Need root priviledge"
	exit 1
fi

usage(){ echo "Usage: ${0} [-r packet rate]"; exit 1; }

while getopts ":r:" arg; do
	case "${arg}" in
		r)
			rate=${OPTARG}
			;;
		h | *)
			usage
			;;
	esac
done

echo "Packet rate: ${rate}, Packet size: ${size}"

cd $MOONGEN_DIR

sudo ./build/MoonGen "${CURR_DIR}"/imix.lua 0 1 -r "${rate}"
