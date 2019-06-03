#!/bin/bash

sudo killall vpp_main       || true
sudo rm /dev/hugepages/* 2>/dev/null
