#!/bin/bash

export VM_NAME=vhost-vm1
export GUEST_MEM=4096M
export QCOW2_IMAGE=/home/tianzhu/centos7.qcow2
export CDROM=/home/tianzhu/CentOS-7-x86_64-Azure-vm2.qcow2
export VHOST_SOCK_DIR=/tmp/bess

sudo mkdir -p ${VHOST_SOCK_DIR}

cd /home/tianzhu/qemu/bin/x86_64-softmmu/

sudo taskset -c 5-8 /usr/bin/qemu-system-x86_64 -name $VM_NAME -cpu host -enable-kvm \
 -m ${GUEST_MEM} -drive file=$CDROM --nographic \
 -chardev socket,id=mychr2,path=${VHOST_SOCK_DIR}/vhost-user-2 \
 -netdev vhost-user,id=mydev2,chardev=mychr2,vhostforce,queues=1 \
 -device virtio-net-pci,netdev=mydev2,mac=00:00:00:00:00:03 \
 -chardev socket,id=mychr3,path=${VHOST_SOCK_DIR}/vhost-user-3 \
 -netdev vhost-user,id=mydev3,chardev=mychr3,vhostforce,queues=1 \
 -device virtio-net-pci,netdev=mydev3,mac=00:00:00:00:00:04 \
 -object memory-backend-file,id=mem,size=${GUEST_MEM},mem-path=/dev/hugepages,share=on \
 -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
 -net user,hostfwd=tcp::10030-:22 -net nic
