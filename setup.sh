#!/bin/bash

DPDK_VERSION=18.11.2

## Put everything into the "/tmp/tools" directory
mkdir -p /tmp/tools

cd /tmp/tools

## Install the relevant tools

## 1. DPDK 18.11 LTS
wget https://fast.dpdk.org/rel/dpdk-${DPDK_VERSION}.tar.xz
tar xvf dpdk-${DPDK_VERSION}.tar.xz

export RTE_SDK="$(pwd)/dpdk-stable-${DPDK_VERSION}"
export RTE_TARGET=x86_64-native-linuxapp-gcc

cd "${RTE_SDK}"
make install T="${RTE_TARGET}"

sudo rmmod igb_uio
cd "${RTE_TARGET}/kmod"; sudo insmod igb_uio.ko
cd -

cd ..
rm -f "dpdk-${DPDK_VERSION}.tar.xz"

## 2. MoonGen
git clone https://github.com/emmericp/MoonGen.git

cd MoonGen

sudo apt-get install -y build-essential cmake linux-headers-`uname -r` pciutils libnuma-dev
./build.sh

cd ..

## 3. FastClick
git clone https://github.com/tbarbette/fastclick.git

cd fastclick

./configure --enable-multithread --disable-linuxmodule --enable-intel-cpu \
	--enable-user-multithread --verbose CFLAGS="-g -O3" CXXFLAGS="-g -std=gnu++11 -O3" \
	--disable-dynamic-linking --enable-poll --enable-bound-port-transfer --enable-dpdk --enable-batch \
	--with-netmap=no --enable-zerocopy --disable-dpdk-pool --disable-dpdk-packet

sudo make -j40

cd ..

## 4. snabb
git clone https://github.com/SnabbCo/snabb
cd snabb
make -j

cd ..

## 5. BESS
wget https://github.com/NetSys/bess/releases/download/v0.4.0/bess-haswell-linux.tar.gz
sudo apt-get install -y python python-pip libgraph-easy-perl
python -m pip install --upgrade pip
pip install --user protobuf grpcio scapy
sudo python -m pip install grpcio --ignore-installed
sudo python -m pip install protobuf --ignore-installed
sudo sysctl vm.nr_hugepages=1024  # For single NUMA node systems
tar xvf bess-haswell-linux.tar.gz
bess-haswell-linux.tar.gz
cd bess
make -C core/kmod
cd ..

## 6. VPP
git clone https://gerrit.fd.io/r/vpp
cd vpp
make install-dep
make bootstrap
make build-release
cd ..

## 7. netmap/VALE
git clone https://github.com/luigirizzo/netmap.git
cd netmap
./configure && sudo make
sudo make install
sudo insmod netmap
cd ..

## 8. OVS-DPDK
export DPDK_BUILD="${RTE_SDK}/${RTE_TARGET}"
git clone https://github.com/openvswitch/ovs.git
cd ovs
./boot.sh
./configure --with-dpdk=$DPDK_BUILD
make && sudo make install
cd ..


## 9. t4p4s
sudo apt-get remove llvm-3.8-runtime llvm-runtime
sudo apt-get install llvm-3.9*

git clone https://github.com/P4ELTE/t4p4s.git
cd t4p4s
. ./t4p4s_environment_variables.sh
cd ..
