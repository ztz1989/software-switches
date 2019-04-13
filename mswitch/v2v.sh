#!/bin/bash

sudo vale-ctl -d vale0:v2 2> /dev/null
sudo vale-ctl -r v2 2> /dev/null
sudo vale-ctl -d vale0:v3 2> /dev/null
sudo vale-ctl -r v3 2> /dev/null

sudo vale-ctl -d vale0:enp11s0f0 2> /dev/null
sudo vale-ctl -d vale0:enp11s0f1 2> /dev/null

sudo vale-ctl -n v2
sudo taskset -c 9-10 vale-ctl -a vale0:v2
sudo vale-ctl -n v3
sudo taskset -c 9-10 vale-ctl -a vale0:v3

echo 'Start Centos VM..'

sudo taskset -c 2-4 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure.qcow2 \
     --enable-kvm -smp 2 -m 4G -nographic -cpu host \
     -device ptnet-pci,netdev=data,mac=00:AA:BB:CC:01:11 \
     -netdev netmap,ifname=vale0:v2,id=data,passthrough=on -vnc :4 \
	 -net nic -net user,hostfwd=tcp::10020-:22
