#!/bin/bash

sudo vale-ctl -d vale2:v6 2> /dev/null
sudo vale-ctl -r v6 2> /dev/null
sudo vale-ctl -d vale3:v7 2> /dev/null
sudo vale-ctl -r v7 2> /dev/null

sudo vale-ctl -n v6
sudo vale-ctl -a vale2:v6
sudo vale-ctl -n v7
sudo vale-ctl -a vale3:v7

echo 'Start Centos VM..'

sudo taskset -c 24-27 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure-vm3.qcow2 \
     --enable-kvm -smp 4 -m 4G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:05 \
     -netdev netmap,ifname=vale2:v6,id=data1,passthrough=on -vnc :8 \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:06 \
     -netdev netmap,ifname=vale3:v7,id=data2,passthrough=on -vnc :9 \
     -net nic -net user,hostfwd=tcp::10040-:22
