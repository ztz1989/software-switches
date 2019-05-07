#!/bin/bash

sudo vale-ctl -d vale1:v4 2> /dev/null
sudo vale-ctl -r v4 2> /dev/null
sudo vale-ctl -d vale2:v5 2> /dev/null
sudo vale-ctl -r v5 2> /dev/null

sudo vale-ctl -n v4
sudo vale-ctl -a vale1:v4
sudo vale-ctl -n v5
sudo vale-ctl -a vale2:v5

sudo vale-ctl -a vale2:enp11s0f1

echo 'Start Centos VM..'

sudo taskset -c 5-8 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure-vm2.qcow2 \
     --enable-kvm -smp 4 -m 4G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:03 \
     -netdev netmap,ifname=vale1:v4,id=data1,passthrough=on -vnc :6 \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:04 \
     -netdev netmap,ifname=vale2:v5,id=data2,passthrough=on -vnc :7 \
     -net nic -net user,hostfwd=tcp::10030-:22
