#!/bin/bash

#initialise variables
rates_array=(385 3850 6930)

file_array=("fx_0.5Gbps_trainData3" "fx_5Gbps_trainData3" "fx_9Gbps_trainData3")

echo "starting BESS"
./start_bess.sh

for i in 0 1 2
do

	echo "starting perf and sleep 5 secs"
	echo "Perf printing to ${file_array[$i]}.csv"
	sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${file_array[$i]}.csv" -r 1 -p `pidof bessd` -I 100 &
	sleep 5

	echo "starting MoonGen with rate: ${rates_array[$i]} mpbs"
	cd ../moongen
	sudo ./latency-test.sh ${rates_array[i]} 60 &

	echo "sleep 1000 secs"
	sleep 1000

	sudo kill -9 $(pidof perf)
	sleep 5
	echo "program: ${pidArray[0]} (perf), killed"

	pid_moon=$(pidof MoonGen)
	sudo kill -9 $pid_moon
	sleep 5
	echo "program: $pid_moon (MoonGen), killed"

	cd -
done

sudo killall bessd
