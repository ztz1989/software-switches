 #!/bin/bash

#initialise variables
rates_array=(500 5000 9000)

file_array=("fx_0.5Gbps_trainData2" "fx_5Gbps_trainData2" "fx_9Gbps_trainData2")
#file_array=("ps_0.5Gbps_trainData3" "ps_5Gbps_trainData3" "ps_9Gbps_trainData3")
#file_array=("197M_0.5Gbps_testData" "197M_1Gbps_testData" "197M_5Gbps_testData" "197M_9Gbps_testData")
#file_array=("ps_500mbps" "ps_1000mbps" "ps_5000mbps" "ps_9000mbps")
#file_array=("0.5Gbps_testData" "5Gbps_testData" "9Gbps_testData")

echo "starting VPP and sleep 15"
./startup_vpp.sh p2p &
sleep 5
echo "Setup xconnect"
./vppctl_p2p.sh l2patch &
sleep 2
#sudo $BINS/vppctl -s /tmp/cli.sock &
#sleep 5

for i in $(seq 0 2);
do
	echo "starting perf and sleep 5 secs"
	echo "Perf printing to ${file_array[$i]}.csv"
	sudo perf stat -e instructions,branches,branch-misses,branch-load-misses,cache-misses,cache-references,cycles,context-switches,cpu-clock,minor-faults,page-faults,task-clock,bus-cycles,ref-cycles,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-store-misses,LLC-stores,LLC-loads,dTLB-stores,dTLB-load-misses,dTLB-store-misses,iTLB-loads,iTLB-load-misses,node-load-misses,node-loads,node-store-misses,node-stores -x, -o "${file_array[$i]}.csv" -r 1 -p `pidof vpp` -I 100 &
	echo "exit code: $?"
	sleep 5

	echo "starting MoonGen with rate: ${rates_array[$i]} mpbs"
    #cd /usr/local/src/MoonGen/; sudo ./moongen-simple start udp-simple:0:1:rate=${rates_array[i]}mbit/s,ratePattern=poisson &
	#cd /usr/local/src/MoonGen/; sudo ./moongen-simple start load-latency:0:1:rate=${rates_array[i]} &
	#cd /usr/local/src/MoonGen/; sudo ./build/MoonGen examples/pcap/replay-pcap.lua 0 /home/charlie/maccdc2012_00008_197M.pcap -l &
	echo "sleep 20 secs"
	#sleep 20

	#pid=$(pidof perf)
	#pidArray=($pid)
	#sudo kill -9 $pid
	sudo killall perf
	sleep 5
	echo "program: ${pidArray[0]} (perf), killed"

	pid_moon=$(pidof MoonGen)
	sudo killall MoonGen
	sleep 5
	echo "program: $pid_moon (MoonGen), killed"

done

sudo killall vpp_main
