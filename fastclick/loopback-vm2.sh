#!/bin/bash

export VM_NAME=vhost-vm-1
export GUEST_MEM=4096M
export CDROM=path/to/image
export VHOST_SOCK_DIR=/tmp/fastclick

cd paht/to/qemu

sudo taskset -c 5-8 ./bin/x86_64-softmmu/qemu-system-x86_64 -name $VM_NAME -cpu host -enable-kvm \
   -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char2,path=$VHOST_SOCK_DIR/vhost-user-2 \
  -netdev type=vhost-user,id=mynet3,chardev=char2,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:03,netdev=mynet3,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -chardev socket,id=char3,path=$VHOST_SOCK_DIR/vhost-user-3 \
  -netdev type=vhost-user,id=mynet4,chardev=char3,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:04,netdev=mynet4,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -net user,hostfwd=tcp::10030-:22 -net nic
