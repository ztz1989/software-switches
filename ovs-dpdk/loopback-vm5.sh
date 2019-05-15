#!/bin/bash

export VM_NAME=vhost-vm4
export GUEST_MEM=4096M
export QCOW2_IMAGE=/home/tianzhu/centos7.qcow2
export CDROM=/home/tianzhu/CentOS-7-x86_64-Azure-vm5.qcow2
export VHOST_SOCK_DIR=/usr/local/var/run/openvswitch

cd /home/tianzhu/qemu/bin/x86_64-softmmu/
sudo taskset -c 32-35 ./qemu-system-x86_64 -name $VM_NAME -cpu host -enable-kvm \
   -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char8,path=$VHOST_SOCK_DIR/vhost-user-9 \
  -netdev type=vhost-user,id=mynet9,chardev=char8,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:09,netdev=mynet9,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -chardev socket,id=char9,path=$VHOST_SOCK_DIR/vhost-user-10 \
  -netdev type=vhost-user,id=mynet10,chardev=char9,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:10,netdev=mynet10,mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mq=on,vectors=6 \
  -net user,hostfwd=tcp::10060-:22 -net nic
