#!/bin/bash

export VM_NAME2=vhost-vm2
export GUEST_MEM=4096M
export CDROM=path/to/image
export VHOST_SOCK_DIR=/usr/local/var/run/openvswitch

cd /home/tianzhu/qemu/bin/x86_64-softmmu/
sudo numactl --membind=0 --physcpubind=5-8 ./qemu-system-x86_64 -name $VM_NAME2 -cpu host -enable-kvm \
  -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem1 -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem1,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char2,path=$VHOST_SOCK_DIR/vhost-user-2 \
  -netdev type=vhost-user,id=mynet2,chardev=char2,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:03,netdev=mynet2,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -net user,hostfwd=tcp::10030-:22 -net nic
