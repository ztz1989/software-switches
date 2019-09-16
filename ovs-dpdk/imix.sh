#!/bin/bash

if [[ -z "${1}" ]]
then
	rate=10000
else
	rate="${1}"
fi

if [[ -z "${2}" ]]
then
    freq=100
else
    freq="${2}"
fi

echo "starting OVS-DPDK"
./ovs-p2p.sh

out_file="ovs-imix-${rate}-${freq}.csv"
echo "Output file: ${out_file}"
sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${out_file}" -r 1 -p `pidof ovs-vswitchd` -I "${freq}" &

echo "starting MoonGen with rate: ${rate} mpbs, ${freq} ms"
cd ../moongen

r="$(bc <<< "scale=2; ${rate}*4242/4482")"
echo "input parameters to MoonGen: ${r}"

sudo ./imix-test.sh -r "${r}" &

echo "sleep 30 secs"
sleep 30

echo "stop Perf and MoonGen"
sudo kill -9 $(pidof perf)
sleep 5
echo "Perf killed"

pid_moon=$(pidof MoonGen)
sudo kill -9 "${pid_moon}"
sleep 5
echo "MoonGen killed"

cd -

echo "stop ovs-dpdk"
./terminate_ovs-dpdk.sh
