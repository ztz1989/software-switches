## Quick start

Our script are organized as follows: 
In order to start one experiment, it is sufficient to cd into the directory of the considered software switch and follow the instructions. We recommend to start with instructions of [OVS-DPDK](https://github.com/ztz1989/software-switches/tree/artifacts/ovs-dpdk), as some repeated details of the measurement tools are omitted for other switches, for the sake of conciseness.

Considering the fact that our experiments require DPDK-compatible physical NICs to reproduce p2p, p2v, and loopback scenario, we thus recommend the reviewers to begin with v2v scenario that is less hardware dependent.

In particular, all the experiments are based on DPDK-18.11.2. To install it, execute the follow script:

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
