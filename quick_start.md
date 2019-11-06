# Getting started

Considering the fact that our experiments require DPDK-compatible physical NICs to reproduce p2p, p2v, and loopback scenario, we thus recommend the reviewers to begin with v2v scenario that is less hardware dependent. 

## System Requirement
It is recommended to run experiments of v2v test scenario on a commodity server with more than 20GB RAM and 10 logical cores, since user laptops might face memory issues and might also require to install many developement tools. Usually, a industrial standard commodity off-the-shelf (COTS) server would be enough.

## Install DPDK
In particular, all the experiments are based on DPDK-18.11.2. To install it:

	$ export DPDK_VERSION=18.11.2

Install dependencies:

	$ sudo apt-get install libnuma-dev make gcc g++ pkg-config zlib1g-dev git linux-headers-$(uname -r)
	
Put everything into the "/tmp/tools" directory

	$ mkdir -p /tmp/tools
	$ cd /tmp/tools

Download DPDK 18.11(LTS):

	$ wget https://fast.dpdk.org/rel/dpdk-${DPDK_VERSION}.tar.xz
	$ tar xvf dpdk-${DPDK_VERSION}.tar.xz

Export **$RTE_SDK** and **$RTE_TARGET**:

	$ export RTE_SDK="$(pwd)/dpdk-stable-${DPDK_VERSION}"
	$ export RTE_TARGET=x86_64-native-linuxapp-gcc

Compile DPDK

	$ cd "${RTE_SDK}"
	$ make install T="${RTE_TARGET}"

**Note: when the compilation process finishes, a warning message "Installation cannot run with T defined and DESTDIR undefined
" will be displayed. Please just ignore it.**


Load igb_uio module

	$ sudo rmmod igb_uio 2> /dev/null
	$ cd "${RTE_TARGET}/kmod"
	$ sudo modprobe uio
	$ sudo insmod igb_uio.ko

Mount Hugepages for DPDK, 2MB hugepage size is the default:

	$ sudo mkdir -p /mnt/huge
	$ sudo mount -t hugetlbfs nodev /mnt/huge
	$ echo 4096 | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
	
## Install FastClick
Get FastClick source

	$ cd /tmp/tools
	$ git clone https://github.com/tbarbette/fastclick.git
	$ cd fastclick

Configure FastClick with DPDK support:

	$./configure --enable-multithread --disable-linuxmodule --enable-intel-cpu \
		--enable-user-multithread --verbose CFLAGS="-g -O3" CXXFLAGS="-g -std=gnu++11 -O3" \
		--disable-dynamic-linking --enable-poll --enable-bound-port-transfer --enable-dpdk --enable-batch \
		--with-netmap=no --enable-zerocopy --disable-dpdk-pool --disable-dpdk-packet

Compile FastClick:

	$ sudo make -j40

## Reproduce v2v test scenario
Download our provisioned CentOS 7 image ([CentOS-7-x86_64-Azure.qcow2](https://drive.google.com/open?id=1KRqgInvv7cbhd2rYIYCBjsDFOid3fg30)) and put it under /tmp/ directory. As v2v scenario requires two VMs, make a copy of this image and name it to **CentOS-7-x86_64-Azure2.qcow2**

Download our GitHub repo and switch to the artifacts branch:

	$ cd /tmp
	$ git clone https://github.com/ztz1989/software-switches.git
	$ cd software-switches
	$ git checkout artifacts

Go to the directory with fastclick experimental scripts

	$ cd fastclick

Launch FastClick with v2v configuration:

	$ ./fastclick-v2v.sh

Launch the first VM, it takes around 10 seconds to finish initialization.

	$ ./v2v.sh
	
Open a new terminal, login to the first VM with username/password "**root/root**", and then setup dpdk:

	$ ssh root@localhost -p 10020	
	$ cd ~; ./setup.sh     # DPDK provisioning inside virtual machine
	
Launch MoonGen inside the first VM:

	$ cd MoonGen
	$ ./build/MoonGen example/l2-load-latency.lua 0 0
	
Open a new terminal, launch the second VM and wait for around 10 seconds

	$ ./v2v1.sh

Open another terminal, login to the second VM with username/password "**root/root**", and then setup dpdk:
	
	$ ssh root@localhost -p 10030
	$ cd ~; ./setup.sh

Go to the monitor directory and launch FloWatcher-DPDK:

	$ cd monitor
	$ ./build/Flowmon-DPDK -c 7

Observe the measured throughput (in Mpps).
