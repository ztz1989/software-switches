#!/bin/bash

sudo vale-ctl -d vale0:v2 2> /dev/null
sudo vale-ctl -r v2 2> /dev/null
sudo vale-ctl -d vale0:v3 2> /dev/null
sudo vale-ctl -r v3 2> /dev/null

sudo vale-ctl -n v2
sudo vale-ctl -a vale0:v2
sudo vale-ctl -n v3
sudo vale-ctl -a vale0:v3

#sudo ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure.qcow2 -net nic -net netmap,ifname=vale0:v0 -vnc :4 \
#     -nographic -smp 4 -m 4G -cpu host --enable-kvm
#§§ -net nic -net user,hostfwd=tcp::10020-:22

echo 'Start Centos VM..'

sudo ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure.qcow2 \
     --enable-kvm -smp 2 -m 2G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:01 \
     -netdev netmap,ifname=vale0:v2,id=data1,passthrough=on -vnc :4 \
	 -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:02 \
     -netdev netmap,ifname=vale0:v3,id=data2,passthrough=on -vnc :5 \
	 -net nic -net user,hostfwd=tcp::10020-:22
