#!/bin/bash

echo 'Start Centos VM..'

IMAGE=path/to/image
cd path/to/qemu
sudo taskset -c 5-8 ./x86_64-softmmu/qemu-system-x86_64 "${IMAGE}" \
     --enable-kvm -smp 2 -m 2G -nographic -cpu host \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:01 \
     -netdev netmap,ifname=vale0:v3,id=data2,passthrough=on -vnc :5 \
	 -net nic -net user,hostfwd=tcp::10030-:22
