# Comparing the Performance of State-of-the-Art Software Switches for NFV
This repository contains scripts to reproduce all the experiments we conducted to compare performance of seven state-of-the-art software switches, namely OVS-DPDK, VPP, snabb, BESS, netmap, t4p4s, and FastClick. All the results and numbers shown in the slides and papers are reproducible on our server. We expect similar results from other testbeds. So you're welcome to download the scripts and run the tests on your server. Any feedback or suggestions are highly appreciated!!!

We consider 7 state-of-the-art software switches in our project, including:
* OVS-DPDK: an accelerated version of Open vSwitch based on Intel DPDK.
* SnabbSwitch: a modular software switch based on LuaJIT.
* FastClick: a Click modular router based on Intel DPDK.
* BESS (previously named SoftNIC): a software switch aiming at augmenting physical NICs
* netmap (including VALE switch, mSwitch and ptnet): a state-of-the-art high-speed packet I/O frameworks. Its solutions provide L2 switching functionality. We mainly focus on the VALE switch.
* Vector Packet Processing (VPP): an open-source full-fledged software router implemented by Cisco.
* t4p4s: a P4 switch based on Intel DPDK.

The detailed instructions for each considered software switch can be found in the corresponding directories.

## Virtualization environment
This project adopts virtual machines to host virtual network functions (VNFs).

### Virtual Machines
We use QEMU/KVM as hypervisor and instantiate virtual machines from a CentOS image.

#### Version of QEMU
In specific, three versions of QEMU software are used in our experiments:

* QEMU 2.5.0: Originally we ran all the experiments on QEMU 3.0.95. However, we due to a compatibility issue with BESS (https://github.com/NetSys/bess/issues/874), we have to use QEMU 2.5.0 in the end, but the results for other switches don't vary so much.
* QEMU 3.0.95: A modified version for experiments with netmap/VALE, since it supports netmap passthrough (ptnet). More details can be found in https://github.com/vmaffione/qemu. 

#### Image
We choose Centos 7 image. They are available [here](https://cloud.centos.org/centos/7/images/). In our experiments, we have downloaded CentOS-7-x86_64-Azure-vm2.qcow2 image and edit it to allow password access.

#### Examples of configuring VMs
QEMU provides a variety of options to configure virtual machines. 

A sample usage is as follows:

sudo taskset -c 4-7 ./qemu-system-x86_64 -name "${VM_NAME}" -cpu host -enable-kvm \
  -m $GUEST_MEM -drive file="$CDROM" --nographic \
  -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem,size="$GUEST_MEM",mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char0,path=$VHOST_SOCK_DIR/vhost-user-1 \
  -netdev type=vhost-user,id=mynet1,chardev=char0,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:01,netdev=mynet1,mrg_rxbuf=off \
  -chardev socket,id=char1,path=$VHOST_SOCK_DIR/vhost-user-2 \
  -netdev type=vhost-user,id=mynet2,chardev=char1,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:02,netdev=mynet2,mrg_rxbuf=off \
  -net user,hostfwd=tcp::10020-:22 -net nic

In this example, we configure a VM instance with 2 virtual network interfaces, each of which uses the [vhost-user](https://access.redhat.com/solutions/3394851) protocol to exchange packets with software switches running on the host. The ${VHOST_SOCK_DIR} contains the UNIX sockets used for communication with the software virtual switch running on the host machine. The communication is only possible if the software switch uses exactly the same UNIX sockets in its local configuration. To isolate multiple instances of VMs and virtual switches on the same host, we use taskset utility to pin the VM to a specific set of cores. 
In the last line, we configure a host forwarding rule as a shortcut to access the VM from local host, so as to avoid the stochastic foreground output of Centos in the terminal. To use this, just open another terminal and run: ssh root@localhost -p 10020, and login with the same password.

#### Install DPDK from source, detailed instructions can be found from DPDK official website (https://doc.dpdk.org/guides/linux_gsg/build_dpdk.html). Our experiments were based on DPDK 18.11, but newer versions are expected to function as well.

#### Configure DPDK inside the VM, an example is given as follows:
```
#!/bin/bash

sysctl vm.nr_hugepages=1024
mkdir -p /dev/hugepages
mount -t hugetlbfs hugetlbfs /dev/hugepages  # only if not already mounted

modprobe uio
insmod /root/dpdk-18.11/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko

$DPDK_DIR/usertools/dpdk-devbind.py --status
$DPDK_DIR/usertools/dpdk-devbind.py -b igb_uio 00:04.0 
$DPDK_DIR/usertools/dpdk-devbind.py -b igb_uio 00:05.0
```
In this script, we firstly mount and reserve hugepages for DPDK. Then we load DPDK PMD driver (such as igb_uio) into the kernel. Then we bind two physical ports to DPDK using their PCI addresses (04:00.0, 05:00.0).

#### Run VNFs inside the VMs
1. For p2v and v2v tests, install and run FloWatcher-DPDK inside VM to measure throughput. Details can be found in (https://github.com/ztz1989/FloWatcher-DPDK). In addition, we also need MoonGen as TX/RX inside VMs. More details can be found in https://github.com/ztz1989/software-switches/tree/master/moongen.
2. For loopback test, deploy DPDK l2fwd application to forward packets between two virtual interfaces. For more details, refer to (https://doc.dpdk.org/guides-18.08/sample_app_ug/l2_forward_real_virtual.html).

