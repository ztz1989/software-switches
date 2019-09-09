#!/bin/bash

if [[ -z "${1}" ]]
then
	rate=10000
else
	rate="${1}"
fi

if [[ -z "${2}" ]]
then
    size=60
else
    size="${2}"
fi

if [[ -z "${3}" ]]
then
    freq=100
else
    freq="${3}"
fi

echo "starting snabb and sleep for 5 seconds"
./start-snabb.sh p2p &
sleep 5

out_file="snabb-${rate}-${size}-${freq}.csv"
echo "Output file: ${out_file}"

pid=''
j='0'

for i in $(pidof snabb)
do
    if [[ "$j" == '0' ]]
    then
        pid="$i"
        j='1'
    else
        pid="$i,${pid}"
    fi
done

echo "starting perf"
sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${out_file}" -r 1 -p "${pid}" -I "${freq}" &

echo "starting MoonGen with rate: ${rate} mpbs, ${size} bytes, profiling freq ${freq} ms"
cd ../moongen
r="$((rate * size/(size+20)))"
s="$((size - 4))"
echo "input parameters to MoonGen: ${r}, ${s}"

sudo ./latency-test.sh "$r" "$s" &

echo "sleep 30 secs"
sleep 30

echo "stop perf and MoonGen"
sudo kill -9 $(pidof perf)
echo "Perf killed"

pid_moon=$(pidof MoonGen)
sudo kill -9 $pid_moon
echo "MoonGen killed"

cd -

echo "killing snabb"
sudo killall snabb
