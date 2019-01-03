#!/bin/bash

export VM_NAME1=vhost-vm1
export GUEST_MEM=2048M
export CDROM=/home/tianzhu/CentOS-7-x86_64-Azure-vm2.qcow2
export VHOST_SOCK_DIR=/tmp/bess

cd /home/tianzhu/qemu/bin/x86_64-softmmu/
sudo numactl --membind=0 --physcpubind=5-8 ./qemu-system-x86_64 -name $VM_NAME1 -cpu host -enable-kvm \
  -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem1 -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem1,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char1,path=$VHOST_SOCK_DIR/vhost-user-1 \
  -netdev type=vhost-user,id=mynet2,chardev=char1 \
  -device virtio-net-pci,mac=00:00:00:00:00:02,netdev=mynet2,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mrg_rxbuf=off,mq=on,vectors=6 \
  -net user,hostfwd=tcp::10030-:22 -net nic
