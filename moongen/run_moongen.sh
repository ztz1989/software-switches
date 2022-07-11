#!/bin/bash

# This script is created to measure the throughput and latency of Software/Virtual switches

MOONGEN_DIR="/home/tzhang/MoonGen/"
CURR_DIR="$(pwd)"

# default values for packet rates [Mbps] and packet size [bytes]
rate=10000
size=60

if [[ "${UID}" -ne 0 ]]
then
	echo "Need root priviledge to execute"
	exit 1
fi

usage(){ echo "Usage: ${0} [-s packet size][-r packet rate]"; exit 1; }

while getopts ":s:r:" arg; do
	case "${arg}" in
		s)
			size="${OPTARG}"
			;;
		r)
			rate="${OPTARG}"
			;;
		h | *)
			usage
			;;
	esac
done

echo "Packet rate: ${rate}, Packet size: ${size}"

cd "${MOONGEN_DIR}"
sudo ./build/MoonGen "${CURR_DIR}"/"${1}".lua 0 1
