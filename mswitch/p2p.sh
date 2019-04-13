#!/bin/bash

# Start the vale switch
sudo taskset -c 9-10 vale-ctl -a vale0:enp11s0f0
sudo taskset -c 9-10 vale-ctl -a vale0:enp11s0f1

