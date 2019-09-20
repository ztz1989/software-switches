#!/bin/bash

# A script for the p2v test of OVS-DPDK. We attached a pair of physical/virtual interfaces to OVS-DPDK and configured to rely 
# packets between them.

PCI0="0b:00.0"

# Stop running instances
sudo env "PATH=${PATH}" ovs-ctl stop

# Start ovs-dpdk using ovs-ctl script.
sudo env "PATH=${PATH}" ovs-ctl --no-ovs-vswitchd start

export DB_SOCK=/usr/local/var/run/openvswitch/db.sock
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=200
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="2048,0"
sudo env "PATH=${PATH}" ovs-ctl --no-ovsdb-server --db-sock="${DB_SOCK}" start

sudo ovs-vsctl del-br br-acl
sudo ovs-vsctl add-br br-acl -- set bridge br-acl datapath_type=netdev
sudo ovs-vsctl add-port br-acl dpdk-lc0p0 -- set interface dpdk-lc0p0 type=dpdk options:dpdk-devargs="${PCI0}" ofport_request=1

sudo ovs-vsctl add-port br-acl vhost-user-0 -- set Interface vhost-user-0 type=dpdkvhostuser options:n_rxq=1 ofport_request=3

sudo ovs-ofctl add-flow br-acl "in_port=1 actions=3"
sudo ovs-ofctl add-flow br-acl "in_port=3 actions=1"


