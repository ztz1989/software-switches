#!/bin/bash

# Start OpenNetVM manager

cd $ONVM_HOME

./onvm/go.sh 0,2,4,6,8,10 3 -s stdout
