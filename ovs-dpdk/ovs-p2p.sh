#!/bin/bash
# The script to start OVS-DPDK switch. The flow table is populated with simple rules to cross-connect OVS's two interfaces.

# PCI addresses of the two physical interfaces to be attached to OVS-DPDK, modify it to the PCI addresses of your interfaces.
PCI0=0b:00.0
PCI1=0b:00.1

# Stop running instances, ovs-ctl was not configured for sudoer, so we imported local environment variables to sudo.
sudo env "PATH=${PATH}" ovs-ctl stop

# Start ovsdb first.
sudo env "PATH=${PATH}" ovs-ctl --no-ovs-vswitchd start

# Configure and start OVS daemon, we need to configure OVS to run in DPDK mode and specify DPDK parameters such as cores to 
# poll packets and memory on each NUMA node (there are two NUMA nodes on our server).
export DB_SOCK=/usr/local/var/run/openvswitch/db.sock
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=400
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="2048,0"
sudo env "PATH=${PATH}" ovs-ctl --no-ovsdb-server --db-sock="$DB_SOCK" start

sudo ovs-vsctl del-br br-acl
sudo ovs-vsctl add-br br-acl -- set bridge br-acl datapath_type=netdev
sudo ovs-vsctl add-port br-acl dpdk-lc0p0 -- set interface dpdk-lc0p0 type=dpdk options:dpdk-devargs="${PCI0}"
sudo ovs-vsctl add-port br-acl dpdk-lc0p1 -- set interface dpdk-lc0p1 type=dpdk options:dpdk-devargs="${PCI1}"

sudo ovs-ofctl add-flow br-acl "in_port=1 actions=2"
sudo ovs-ofctl add-flow br-acl "in_port=2 actions=1"
