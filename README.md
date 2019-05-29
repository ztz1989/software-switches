# Performance comparison of state-of-the-art software switches
This repository contains scripts to reproduce all the experiments we conducted to compare performance of seven state-of-the-art software switches, namely OVS-DPDK, VPP, snabb, BESS, netmap, t4p4s, etc. All the results and numbers shown in the slides and papers (TBA) are reproducible on our server. We expect similar results from other testbeds. So you're welcome to download the scripts and run the tests on your server. Any feedback or suggestions are highly recommended!!!

We consider six state-of-the-art software switches in our project, including:
* OVS-DPDK
* SnabbSwitch
* FastClick
* BESS (previously named SoftNIC)
* netmap (including VALE switch, mSwitch and ptnet)
* Vector Packet Processing (VPP)
* t4p4s: a P4 switch based on Intel DPDK

The detailed instructions for each considered software switch can be found in the corresponding directories.

## Virtualization environment
This project considers both virtual machines and containers, both of which are essential building blocks in Network Function Virtualization (NFV).

### Virtual Machines
We use QEMU/KVM as hypervisor. 

#### Version of QEMU
In specific, three versions of QEMU software are used in our experiments:

* QEMU 3.0.95: Used for experiments with OVS-DPDK, Snabb, FastClick and ClickNF
* QEMU 2.5.0: Used for experiments with BESS due to a compatibility issue reported by https://github.com/NetSys/bess/issues/874
* QEMU 3.0.95: A modified version for experiments with netmap, since it supports netmap passthrough (ptnet). More details can be found in https://github.com/vmaffione/qemu

#### Image
We choose Centos 7 image. They are available [here](https://cloud.centos.org/centos/7/images/). We expect similar performance using other Linux distributions. In our experiments, we have downloaded CentOS-7-x86_64-Azure-vm2.qcow2 image and edit it to allow password access. The username and password to login to its VMs are both "root".

#### Examples of configuring VMs
QEMU provides a variety of options to configure virtual machines. 

A sample usage is as follows:

sudo taskset -c 4-7 ./qemu-system-x86_64 -name $VM_NAME -cpu host -enable-kvm \
  -m $GUEST_MEM -drive file=$CDROM --nographic \
  -numa node,memdev=mem -mem-prealloc -smp sockets=1,cores=4 \
  -object memory-backend-file,id=mem,size=$GUEST_MEM,mem-path=/dev/hugepages,share=on \
  -chardev socket,id=char0,path=$VHOST_SOCK_DIR/vhost-user-1 \
  -netdev type=vhost-user,id=mynet1,chardev=char0,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:01,netdev=mynet1,mrg_rxbuf=off \
  -chardev socket,id=char1,path=$VHOST_SOCK_DIR/vhost-user-2 \
  -netdev type=vhost-user,id=mynet2,chardev=char1,vhostforce \
  -device virtio-net-pci,mac=00:00:00:00:00:02,netdev=mynet2,mrg_rxbuf=off \
  -net user,hostfwd=tcp::10020-:22 -net nic

In this example, we configure a VM instance with 2 virtual network interfaces, each of which uses the [vhost-user](https://access.redhat.com/solutions/3394851) protocol (in server mode) to exchange packetsw with host machine. The ${VHOST_SOCK_DIR} contains the UNIX sockets used for communication with the software virtual switch running on the host machine. The communication is only possible if the software switch uses exactly the same UNIX sockets in its local configuration. To isolate multiple instances of VMs and virtual switches on the same host, we use taskset utility to pin the VM to a specific set of cores. In the last line, we configure a host forwarding rule as a shortcut to access the VM from local host, so as to avoid the stochastic foreground output of Centos in the terminal. To use this, just open another terminal and run: ssh root@localhost -p 10020, and login with the same password.

### Containers
We use Docker to create and manage containers. The version is 17.03.2-ce, build f5ec1e2. To carry out our experiments with Docker, we firstly build three Docker images, based on which containers are instantiated:
* DPDK container
* FloWatcher-DPDK container
* pktgen-dpdk container

These images are locally generated on our server. The corresponding Docketfiles can be found in Docker/ directory. 

Instructions for starting Docker instances for different test scenarios are available in each sub-directiory. Actually, we dont't need to start a new container everytime since all the containers instances are still reserved in the container pool. We can just restart and jump into their terminals using
  * sudo docker container start -i [container name]


