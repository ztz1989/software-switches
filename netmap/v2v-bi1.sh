#!/bin/bash

echo 'Start Centos VM 2..'

IMAGE=path/to/image
cd path/to/qemu
sudo taskset -c 5-8 ./x86_64-softmmu/qemu-system-x86_64 "${IMAGE}" \
     --enable-kvm -smp 4 -m 4G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:03 \
     -netdev netmap,ifname=vale0:v1,id=data1,passthrough=on -vnc :6 \
     -device ptnet-pci,netdev=data2,mac=00:AA:BB:CC:01:04 \
     -netdev netmap,ifname=vale1:v3,id=data2,passthrough=on -vnc :7 \
     -net nic -net user,hostfwd=tcp::10030-:22
