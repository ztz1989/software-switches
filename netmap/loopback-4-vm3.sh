#!/bin/bash

sudo vale-ctl -d vale3:v8 2> /dev/null
sudo vale-ctl -r v8 2> /dev/null
sudo vale-ctl -d vale4:v9 2> /dev/null
sudo vale-ctl -r v9 2> /dev/null

sudo vale-ctl -n v8
sudo vale-ctl -a vale3:v8
sudo vale-ctl -n v9
sudo vale-ctl -a vale4:v9

sudo vale-ctl -a vale4:enp11s0f1

echo 'Start Centos VM..'

sudo taskset -c 28-31 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure-vm4.qcow2 \
     --enable-kvm -smp 4 -m 4G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:07 \
     -netdev netmap,ifname=vale3:v8,id=data1,passthrough=on -vnc :10 \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:08 \
     -netdev netmap,ifname=vale4:v9,id=data2,passthrough=on -vnc :11 \
     -net nic -net user,hostfwd=tcp::10050-:22
