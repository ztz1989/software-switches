#!/bin/bash

SWITCHES=( ovs-dpdk fastclick vpp bess t4p4s snabb )
#SWITCHES=(t4p4s snabb)
rates=(500 2500 5000 7500 10000)
sizes=(64 128 512 1400)
freqs=(100 1000 5000)

for i in "${SWITCHES[@]}"
do
	echo "Software Switch: $i"
	cd "${i}"

	for r in "${rates[@]}"
	do
		for f in "${freqs[@]}"
		do
			echo "Profiling ${i} with ${r}, ${f}"
			./imix.sh "${r}" "${f}"
		done
	done
	cd ..
done
