#!/bin/bash

export VM_NAME=vhost-vm3
export GUEST_MEM=4096M
export CDROM=path/to/image
export VHOST_SOCK_DIR=/tmp/t4p4s

cd path/to/qemu
sudo taskset -c 28-31 ./bin/x86_64-softmmu/qemu-system-x86_64 -name $VM_NAME -cpu host -enable-kvm \
   -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char6,path=$VHOST_SOCK_DIR/vhost-user-6 \
  -netdev type=vhost-user,id=mynet7,chardev=char6,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:07,netdev=mynet7,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -chardev socket,id=char7,path=$VHOST_SOCK_DIR/vhost-user-7 \
  -netdev type=vhost-user,id=mynet8,chardev=char7,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:08,netdev=mynet8,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -net user,hostfwd=tcp::10050-:22 -net nic
