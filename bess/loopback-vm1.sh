#!/bin/bash

export VM_NAME=vhost-vm
export GUEST_MEM=4096M
export QCOW2_IMAGE=/home/tianzhu/centos7.qcow2
export CDROM=/home/tianzhu/CentOS-7-x86_64-Azure.qcow2
export VHOST_SOCK_DIR=/tmp/bess

sudo mkdir -p ${VHOST_SOCK_DIR}

#cd /home/tianzhu/qemu/bin/x86_64-softmmu/
cd /home/tianzhu/qemu-repo/qemu-2.2.0/x86_64-softmmu/

sudo taskset -c 1-4 ./qemu-system-x86_64  -name $VM_NAME -cpu host -enable-kvm \
 -m ${GUEST_MEM} -drive file=$CDROM --nographic \
 -chardev socket,id=mychr,path=${VHOST_SOCK_DIR}/vhost-user-0 \
 -netdev vhost-user,id=mydev,chardev=mychr,vhostforce \
 -device virtio-net-pci,netdev=mydev,mac=00:00:00:00:00:01 \
 -chardev socket,id=mychr1,path=${VHOST_SOCK_DIR}/vhost-user-1 \
 -netdev vhost-user,id=mydev1,chardev=mychr1,vhostforce \
 -device virtio-net-pci,netdev=mydev1,mac=00:00:00:00:00:02 \
 -object memory-backend-file,id=mem,size=${GUEST_MEM},mem-path=/dev/hugepages,share=on \
 -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
 -net user,hostfwd=tcp::10020-:22 -net nic
