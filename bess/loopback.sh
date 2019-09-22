#!/bin/bash

export VM_NAME=vhost-vm
export GUEST_MEM=4096M
export CDROM=path/to/image
export VHOST_SOCK_DIR=/tmp/bess

sudo mkdir -p ${VHOST_SOCK_DIR}

cd path/to/qemu

sudo taskset -c 1-4 ./bin/x86_64-softmmu/qemu-system-x86_64 -name $VM_NAME -cpu host -enable-kvm \
 -m ${GUEST_MEM} -drive file=$CDROM --nographic \
 -chardev socket,id=mychr,path=${VHOST_SOCK_DIR}/vhost-user-0 \
 -netdev vhost-user,id=mydev,chardev=mychr,vhostforce,queues=1 \
 -device virtio-net-pci,netdev=mydev,mac=00:00:00:00:00:01 \
 -chardev socket,id=mychr1,path=${VHOST_SOCK_DIR}/vhost-user-1 \
 -netdev vhost-user,id=mydev1,chardev=mychr1,vhostforce,queues=1 \
 -device virtio-net-pci,netdev=mydev1,mac=00:00:00:00:00:02 \
 -object memory-backend-file,id=mem,size=${GUEST_MEM},mem-path=/dev/hugepages,share=on \
 -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
 -net user,hostfwd=tcp::10020-:22 -net nic
