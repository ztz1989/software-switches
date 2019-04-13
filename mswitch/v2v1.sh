#!/bin/bash

echo 'Start Centos VM..'

sudo taskset -c 5-7 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure-vm2.qcow2 \
     --enable-kvm -smp 2 -m 2G -nographic -cpu host \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:01 \
     -netdev netmap,ifname=vale0:v3,id=data2,passthrough=on -vnc :5 \
	 -net nic -net user,hostfwd=tcp::10030-:22
