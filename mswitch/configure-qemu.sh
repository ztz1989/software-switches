#!/bin/bash

cd qemu

./configure --target-list=x86_64-softmmu --enable-kvm --enable-vhost-net --disable-werror --enable-netmap --extra-cflags=-I/home/tianzhu/netmap/sys

make
