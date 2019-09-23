# Virtualization environment and VNFs
This project adopts virtual machines (VMs) to host virtual network functions (VNFs). Other virtualization techniques such as container are considered for future work. We use QEMU/KVM as hypervisor and instantiate virtual machines from a CentOS image.

Since the 7 software switches under test are based on different implementation techniques, we cannot always use the same tools in some test scenarios. For example, in terms of packet I/O techniques, VALE is based on the netmap, snabb implements its own while other solutions are based on Intel DPDK. We will point out these difference as much as possible in the following sections. 

## Configuration of virtual machines
### VM Image
We choose Centos images available [here](https://cloud.centos.org/centos/7/images/). In our experiments, we have used the **CentOS-7-x86_64-Azure-vm2.qcow2** image. All the virtual machines are instantiated from duplications of this image to ensure fairness.

Note that we modified it to allow password access. This can be done using the image editing tools.

### Version of QEMU hypervisor
In specific, two versions of QEMU/KVM hypervisor are used in our experiments:
* QEMU 2.5.0: Originally we ran all the experiments on QEMU 3.0.95. However, due to a compatibility issue with BESS as reported [here](https://github.com/NetSys/bess/issues/874), we had to use QEMU 2.5.0 in the end, but the results didn't vary so much.
* netmap QEMU 3.0.95: this is a modified version for netmap applications to interact with virtual machines, as it supports netmap passthrough (ptnet). More details can be found in https://github.com/vmaffione/qemu.

### VMs for DPDK-based solutions and snabb
An example usage with `virtio-net` interfaces with `vhost-user` backend is shown as follows:
```
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
```

In this example, we configure a VM instance with 2 virtio-net frontend interfaces, each of which uses the [vhost-user](https://access.redhat.com/solutions/3394851) protocol as backend to exchange packets with user-space software switches running on the host. The ${VHOST_SOCK_DIR} contains the UNIX sockets used for communication with the software virtual switch running on the host machine. The communication is only possible if the software switch under test uses exactly the same UNIX sockets in its configuration. 

There are several other options that are critical to reproduce the experiments:
* **-device**: specify the virtual interface type, we chose `virtio-net` device. 
* **netdev**: we specify `vhost-user` as the backend for the `virtio` interfaces.
* **-m**: specify the amount of required memory, e.g., 2048M.
* **mem-path**: allocate hugepages to the VM.
* **-cpu host**: emulate CPU host processor.
* **-smp**: specify the number of cores dedicated to the VM.
* **-numa**: emulate NUMA nodes on VM. We used a single NUMA node for the VM.
* **secure shell**: in the last line, we configure a host forwarding rule as a shortcut to access the VM from more than one terminal by typing **ssh root@localhost -p 10020**.

### VMs for netmap/VALE
To support the `ptnet` mechanism, we need to build netmap's QEMU hypervisor as detailed [here](https://github.com/vmaffione/qemu). An example to instantiate VM supporting ptnet interfaces is illustrated as follows:
```
sudo taskset -c 1-4 ./qemu/x86_64-softmmu/qemu-system-x86_64 CentOS-7-x86_64-Azure.qcow2 \
     --enable-kvm -smp 2 -m 2G -nographic -cpu host \
     -device ptnet-pci,netdev=data1,mac=00:AA:BB:CC:01:01 \
     -netdev netmap,ifname=vale0:v2,id=data1,passthrough=on -vnc :4 \
     -net nic -net user,hostfwd=tcp::10020-:22
```
Note that we need to specify the virtual device type as `ptnet-pci`. The backend can be any netmap/VALE interfaces. We specify a VALE interface here.

## Configuration of VNFs inside the virtual machines
1. DPDK: install DPDK from source, detailed instructions can be found from DPDK official website (https://doc.dpdk.org/guides/linux_gsg/build_dpdk.html). Our experiments were based on DPDK 18.11, but newer versions are expected to function as well. A simple example is given as follows:
```
#!/bin/bash

# mount and reserve hugepages
sysctl vm.nr_hugepages=1024
mkdir -p /dev/hugepages
mount -t hugetlbfs hugetlbfs /dev/hugepages

# load igb_uio module
modprobe uio
insmod /root/dpdk-18.11/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko

# bind the devices to DPDK
$DPDK_DIR/usertools/dpdk-devbind.py --status
$DPDK_DIR/usertools/dpdk-devbind.py -b igb_uio 00:04.0 
$DPDK_DIR/usertools/dpdk-devbind.py -b igb_uio 00:05.0
```
In this script, we firstly mount and reserve hugepages for DPDK. Then we load DPDK PMD driver (such as igb_uio) into the kernel. Then we bind two virtualized ports to DPDK using their PCI addresses (04:00.0, 05:00.0).
2. MoonGen: build MoonGen inside the VM. More details can be found [here](https://github.com/ztz1989/software-switches/tree/master/moongen).
3. FloWatcher-DPDK: Details can be found in (https://github.com/ztz1989/FloWatcher-DPDK).
