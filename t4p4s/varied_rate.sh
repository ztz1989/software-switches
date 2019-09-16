#!/bin/bash

sudo killall l2fwd 2> /dev/null

echo "starting t4p4s"
sudo -E ./start_t4p4s.sh p2p &
echo "Sleep for 15s"
sleep 15

if [[ -z "${1}" ]];then
    pattern="cbr"
else
    pattern="${1}"
fi

out_file="t4p4s-varied_${pattern}_rate.csv"
echo "Output file: ${out_file}"

echo "starting perf"
sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${out_file}" -r 1 -p `pidof l2fwd` -I 1000 &

echo "starting MoonGen with varied, 60 bytes, profiling freq 1s"
cd ../moongen

sudo /usr/local/src/MoonGen/build/MoonGen ./varied_"${pattern}"_rate.lua 0 1

echo "sleep 30 secs"
sleep 30

echo "stop perf and MoonGen"
sudo kill -9 $(pidof perf)
sleep 5
echo "Perf killed"

pid_moon=$(pidof MoonGen)
sudo kill -9 $pid_moon
sleep 5
echo "MoonGen killed"

cd -

echo "killing l2fwd"
sudo killall l2fwd
sleep 2
