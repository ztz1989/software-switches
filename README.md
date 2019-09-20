# Comparing the Performance of State-of-the-Art Software Switches for NFV
This repository contains scripts to reproduce all the experiments we conducted to compare performance of seven state-of-the-art software switches, namely OVS-DPDK, VPP, snabb, BESS, VALE, t4p4s, and FastClick. All the results and numbers shown in the slides and papers are reproducible on our server. We expect similar results from other testbeds. So you're welcome to download the scripts and run the tests on your server. Any feedback or suggestions are highly appreciated!!! 

We consider 7 state-of-the-art software switches in our project, including:
* [OVS-DPDK](http://docs.openvswitch.org/en/latest/intro/install/dpdk/): an accelerated version of Open vSwitch based on Intel DPDK.
* [SnabbSwitch](https://github.com/snabbco/snabb): a modular software switch based on LuaJIT.
* [FastClick](https://github.com/tbarbette/fastclick): a Click modular router based on Intel DPDK.
* [BESS](https://github.com/NetSys/bess) (previously named SoftNIC): a software switch aiming at augmenting physical NICs
* [netmap](https://github.com/luigirizzo/netmap) (including VALE switch, mSwitch and ptnet): a state-of-the-art high-speed packet I/O frameworks. Its solutions provide L2 switching functionality. We mainly focus on the VALE switch.
* [VPP](https://github.com/FDio/vpp): an open-source full-fledged software router implemented by Cisco.
* [t4p4s](https://github.com/P4ELTE/t4p4s): a P4 switch based on Intel DPDK.

## Introduction
We performed performance comparison under 4 test scenarios: p2p, p2v, v2v, and loopback.

A detailed description of test scenarios and experimental results can be found on [our demo website](https://ztz1989.github.io/software-switches.github.io/examples/dashboard.html). The detailed instructions for each considered software switch can be found as follows:
* [OVS-DPDK](https://github.com/ztz1989/software-switches/tree/artifacts/ovs-dpdk)
* [FastClick](https://github.com/ztz1989/software-switches/tree/artifacts/fastclick)
* [BESS](https://github.com/ztz1989/software-switches/tree/artifacts/bess)
* [VPP](https://github.com/ztz1989/software-switches/tree/artifacts/vpp)
* [t4p4s](https://github.com/ztz1989/software-switches/tree/artifacts/t4p4s)
* [snabb](https://github.com/ztz1989/software-switches/tree/artifacts/snabb)
* [VALE](https://github.com/ztz1989/software-switches/tree/artifacts/netmap)

We recommend to start with instructions of [OVS-DPDK](https://github.com/ztz1989/software-switches/tree/artifacts/ovs-dpdk), as some repeated details are omitted.

## Tools
Our experiments adopted several software tools for different test scenarios

* [MoonGen](https://github.com/ztz1989/software-switches/blob/artifacts/README-VM.md): A high-speed traffic generator based on LuaJIT and DPDK. 
* [FloWatcher-DPDK](https://github.com/ztz1989/FloWatcher-DPDK): A lightweight software traffic monitor.
* [pkt-gen](https://github.com/luigirizzo/netmap/tree/master/apps/pkt-gen): A high-speed traffic generator based on netmap API.
* [DPDK l2fwd](https://doc.dpdk.org/guides-18.08/sample_app_ug/l2_forward_real_virtual.html): DPDK L2 fowarding sample application.

## Quick start

Our script are organized as follows. 
In order to start one experiment, it is sufficient to cd into the directory of the considered software switch and follow the instructions.

The naming convention for the scritp is the following: ``` [switch-name]-[experiment-type].sh "[pktsize argument]" ```.
Where:

```
switch-name={ovs-dpdk, fastclick, vpp, bess, t4p4s, snabb, netmap}
experiment-type= {p2p, p2v, v2v, loopback}

```

---

**WARNING!! For each switch there are specific tunings to be made.**

---


### Example 1 : P2P scenario for all switch

```
# Quick Start for a p2p experiment for all switches
SWITCHES=( ovs-dpdk fastclick vpp bess t4p4s snabb )
sizes=(64 250 1024)

for i in "${SWITCHES[@]}"
do
	echo "Software Switch: $i"
	cd "${i}"

  for s in "${sizes[@]}"
		do
			for f in "${freqs[@]}"
			do
				./${i}-p2p.sh "${s}"
			done
		done
	cd ..
done
```

### Example 2: P2V scenario for a single switch

To try the p2v experiment for a single switch, please use the syntax:


```
switch="[switch-name]"
pktsize="[size]"

cd ${switch}

./${switch}-p2v.sh "${pktsize}"

```


