#!/bin/bash

sudo vale-ctl -d vale4:v10 2> /dev/null
sudo vale-ctl -r v10 2> /dev/null
sudo vale-ctl -d vale6:v11 2> /dev/null
sudo vale-ctl -r v11 2> /dev/null

sudo vale-ctl -n v10
sudo vale-ctl -a vale4:v10
sudo vale-ctl -n v11
sudo vale-ctl -a vale6:v11

sudo vale-ctl -a vale6:enp11s0f1

echo 'Start Centos VM..'

sudo taskset -c 32-35 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure-vm5.qcow2 \
     --enable-kvm -smp 4 -m 4G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:09 \
     -netdev netmap,ifname=vale4:v10,id=data1,passthrough=on -vnc :12 \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:10 \
     -netdev netmap,ifname=vale6:v11,id=data2,passthrough=on -vnc :13 \
     -net nic -net user,hostfwd=tcp::10060-:22
