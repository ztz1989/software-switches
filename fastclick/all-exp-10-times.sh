#!/bin/bash

# CBR tests
: '
for i in $(seq 1 10);do
	echo "Experiment ${i}"
	for r in $(seq 500 500 10000);do
		for s in 64 256;do
			out_file="fastclick-cbr-10-times-${r}-${s}-${i}.csv"
			./fastclick-p2p.sh &
			sleep 20

			cd ../moongen

            rate="$((r * s/(s+20)))"
            size="$((s - 4))"
            echo "input parameters to MoonGen: ${r}, ${s}"
            sudo ./latency-test.sh "${rate}" "${size}" &

			cd -
			sleep 20

			sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${out_file}" -r 1 -p `pidof click` -I 1000 &
			sleep 30

			sudo killall perf
			sudo killall MoonGen
			sudo killall click
			sleep 5
		done
	done
done

# imix test
echo "imix test"
for i in $(seq 1 10);do
    echo "Experiment ${i}"
    for r in $(seq 500 500 10000);do
        #for s in 64 256;do
            out_file="fastclick-imix-10-times-${r}-${i}.csv"
            ./fastclick-p2p.sh &
            sleep 20

            cd ../moongen

			rate="$(bc <<< "scale=2; ${r}*4242/4482")"
			echo "input parameters to MoonGen: ${r}"

			sudo ./imix-test.sh -r "${rate}" &

            cd -
            sleep 20

			sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${out_file}" -r 1 -p `pidof click` -I 1000 &
            sleep 30

            sudo killall perf
            sudo killall MoonGen
            sudo killall click
            sleep 5
        #done
    done
done
'
# poisson test
echo "poisson test"
for i in $(seq 1 10);do
    echo "Experiment ${i}"
    for r in $(seq 500 500 10000);do
        for s in 64 256;do
            out_file="fastclick-poisson-10-times-${r}-${s}-${i}.csv"
            ./fastclick-p2p.sh &
            sleep 20

            cd ../moongen

			rate="$(bc <<< "scale=2; $r/($s+20)/8")"
			size="$((s - 4))"
			echo "input parameters to MoonGen: ${rate}, ${size}"
			sudo ./poisson-test.sh -r "${rate}" -s "${size}" &

            cd -
            sleep 20

			sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${out_file}" -r 1 -p `pidof click` -I 1000 &
            sleep 30

            sudo killall perf
            sudo killall MoonGen
            sudo killall click
            sleep 5
        done
    done
done
