#!/bin/bash

sudo vale-ctl -d vale0:enp11s0f0 2> /dev/null
sudo vale-ctl -d vale0:enp11s0f1 2> /dev/null
sudo vale-ctl -d vale1:enp11s0f1 2> /dev/null

sudo vale-ctl -d vale0:v2 2> /dev/null
sudo vale-ctl -d vale0:v3 2> /dev/null

sudo vale-ctl -d vale1:v3 2> /dev/null
