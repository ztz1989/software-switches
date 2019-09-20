## Virtualization environment
This project adopts virtual machines (VMs) to host virtual network functions (VNFs). Other virtualization techniques such as container are considered for future work. We use QEMU/KVM as hypervisor and instantiate virtual machines from a CentOS image.

#### Version of QEMU
In specific, two versions of QEMU software are used in our experiments:

* QEMU 2.5.0: Originally we ran all the experiments on QEMU 3.0.95. However, due to a compatibility issue with BESS as reported [here](https://github.com/NetSys/bess/issues/874), we had to use QEMU 2.5.0 in the end, but the results didn't vary so much.
* QEMU 3.0.95: A modified version for experiments with netmap/VALE, since it supports netmap passthrough (ptnet). More details can be found in https://github.com/vmaffione/qemu.

#### VM Image
We choose Centos 7 image. They are available [here](https://cloud.centos.org/centos/7/images/). In our experiments, we have used the **CentOS-7-x86_64-Azure-vm2.qcow2** image and modified it to allow password access.

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

In this example, we configure a VM instance with 2 virtual network interfaces, each of which uses the [vhost-user](https://access.redhat.com/solutions/3394851) protocol to exchange packets with software switches running on the host. The ${VHOST_SOCK_DIR} contains the UNIX sockets used for communication with the software virtual switch running on the host machine. The communication is only possible if the software switch uses exactly the same UNIX sockets in its local configuration. In the last line, we configure a host forwarding rule as a shortcut to access the VM from another terminal, so as to avoid the noisy syslog output of Centos in the terminal. To use this, just open another terminal and run: ssh root@localhost -p 10020, and login with the same password.

#### Install DPDK from source, detailed instructions can be found from DPDK official website (https://doc.dpdk.org/guides/linux_gsg/build_dpdk.html). Our experiments were based on DPDK 18.11, but newer versions are expected to function as well.

#### Configure DPDK inside the VM, an example is given as follows:
```
#!/bin/bash

# mount and reserve hugepages
sysctl vm.nr_hugepages=1024
mkdir -p /dev/hugepages
mount -t hugetlbfs hugetlbfs /dev/hugepages

# load igb_uio module
modprobe uio
insmod /root/dpdk-18.11/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko

# bind the virtual devices to DPDK
$DPDK_DIR/usertools/dpdk-devbind.py --status
$DPDK_DIR/usertools/dpdk-devbind.py -b igb_uio 00:04.0 
$DPDK_DIR/usertools/dpdk-devbind.py -b igb_uio 00:05.0
```
In this script, we firstly mount and reserve hugepages for DPDK. Then we load DPDK PMD driver (such as igb_uio) into the kernel. Then we bind two virtualized ports to DPDK using their PCI addresses (04:00.0, 05:00.0).

#### Run VNFs inside the VMs
1. For p2v and v2v tests, install and run FloWatcher-DPDK inside VM to measure throughput. Details can be found in (https://github.com/ztz1989/FloWatcher-DPDK). In addition, we also need MoonGen as TX/RX inside VMs. More details can be found in https://github.com/ztz1989/software-switches/tree/master/moongen.
2. For loopback test, deploy DPDK l2fwd application to forward packets between two virtual interfaces. For more details, refer to (https://doc.dpdk.org/guides-18.08/sample_app_ug/l2_forward_real_virtual.html).
