#!/bin/bash

export VPP_ROOT='/home/tianzhu/vpp-19.04/vpp'
export STARTUP_CONF='startup-p2p.conf'
export NAMELC0P0="TenGigabitEthernetb/0/0"
export NAMELC0P1="VhostEthernet1"

echo "Preparing path"

BINS="$VPP_ROOT/build-root/install-vpp-native/vpp/bin"
PLUGS="$VPP_ROOT/build-root/install-vpp-native/vpp/lib64/vpp_plugins"
SFLAG="env PATH=$PATH:$BINS"

PREFIX=`cat $STARTUP_CONF | grep cli-listen | awk '{print $2}' | xargs echo -n`

cd $VPP_ROOT

if [[ "$#" -eq 0 ]]; then
	sudo $BINS/vppctl -s $PREFIX set int l2 xconnect $NAMELC0P1 $NAMELC0P0
	sudo $BINS/vppctl -s $PREFIX set int l2 xconnect $NAMELC0P0 $NAMELC0P1
else
	sudo $BINS/vppctl -s $PREFIX test l2patch rx $NAMELC0P0 tx $NAMELC0P1
	sudo $BINS/vppctl -s $PREFIX test l2patch rx $NAMELC0P1 tx $NAMELC0P0
fi

sudo $BINS/vppctl -s $PREFIX set int state $NAMELC0P0 up
sudo $BINS/vppctl -s $PREFIX set int state $NAMELC0P1 up

echo "Done Configuration"
exit 1
