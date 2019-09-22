#!/bin/bash

export VM_NAME1=vhost-vm1
export GUEST_MEM=4096M
export CDROM=path/to/image
export VHOST_SOCK_DIR=/tmp/t4p4s

cd path/to/qemu
sudo taskset -c 5-8 ./bin/x86_64-softmmu/qemu-system-x86_64 -name $VM_NAME1 -cpu host -enable-kvm \
  -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem1 -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem1,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char1,path=$VHOST_SOCK_DIR/vhost-user-1 \
  -netdev type=vhost-user,id=mynet2,chardev=char1,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:02,netdev=mynet2,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -net user,hostfwd=tcp::10030-:22 -net nic
