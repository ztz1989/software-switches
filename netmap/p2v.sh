#!/bin/bash

sudo vale-ctl -d vale0:v2 2> /dev/null
sudo vale-ctl -r v2 2> /dev/null
sudo vale-ctl -d vale0:enp11s0f1 2> /dev/null
sudo vale-ctl -d vale0:v1 2> /dev/null

sudo vale-ctl -n v2
sudo vale-ctl -a vale0:v2

sudo vale-ctl -a vale0:enp11s0f0

echo 'Start Centos VM..'

IMAGE=path/to/image
cd path/to/qemu
sudo taskset -c 1-4 ./x86_64-softmmu/qemu-system-x86_64 "${IMAGE}" \
     --enable-kvm -smp 2 -m 2G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:01 \
     -netdev netmap,ifname=vale0:v2,id=data1,passthrough=on -vnc :4 \
	 -net nic -net user,hostfwd=tcp::10020-:22
