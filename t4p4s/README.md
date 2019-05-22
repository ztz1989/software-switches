# Performance test for the t4p4s switch

This directory contains scripts to perform p2p, p2v and v2v tests. More details about t4p4s can be found in its 
[repository](https://github.com/P4ELTE/t4p4s)

## p2p test:
- in the start_t4p4s.sh script, modify the $T4P4s_DIR to the corresponding path on your server
- in p2p.cfg configuration file, line 8: change the PCI addresses (after -w) to the physical interfaces to be attached to t4p4s switch on your server. 
  Note that this is just the DPDK whitelist commandline option. The specified interfaces will be granted a DPDK device number
  starting from 0.
- start t4p4s switch for p2p test: **./start_t4p4s.sh p2p**
- launch MoonGen to inject packets externally to the physical interfaces, both unidirectionally or bidirectionally. 
  Note that t4p4s uses a default Match/Action table to forward packets. The default Match field is the destination MAC address. 
  The table is shown here. Part of it looks like this:
  
  | Dst MAC  | Out_port |
  |------------------|--|
  |aa:cc:dd:cc:00:01 | 1|
  |aa:bb:bb:aa:00:01 | 0|
  
  To make the switch forward packets properly, **the injected packets must have the corrsponding destination MAC address and 
  the matched out_port cannot be the same as in_port, or t4p4s will simply crash.**
  
## p2v test:
- in the p2v.cfg configuration file, line 8: specify your intended virtual device with the Unix socket path through the DPDK --vdev option. Also whitelist the PCI address of the physical interface using -w option.
- start t4p4s switch: **./start_t4p4s.sh p2v**
- launch a VM instance with a virtio interface connected through the specified socket path, using the p2v.sh script.
- launch MoonGen and inject traffic to the specified physical interface.
- inside the VM, launch a FloWatcher-DPDK instance to measure the forwarding throughput.

## v2v test:
- in the v2v.cfg configuration file, specify two virtual devices
- start t4p4s switch: **./start_t4p4s.sh v2v**
- launch two VMs using
  - *./v2v.sh
  - *./v2v1.sh
- on the first VM, start MoonGen to transmit packets to its virtual interface from inside.
- on the second VM, start FloWatcher-DPDK to measure forwarding throughput of t4p4s switch.

