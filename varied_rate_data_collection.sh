#!/bin/bash

SWITCHES=( ovs-dpdk fastclick vpp bess t4p4s snabb)

for i in "${SWITCHES[@]}"
do
	echo "Software Switch: ${i}"
	cd "${i}"

	#./varied_rate.sh cbr
	#./varied_rate.sh poisson
	./varied_rate.sh imix
	cd ..
done
