#!/bin/bash

awk -v max=0 -F',' '{max+=$1*$2;sample+=$2}END{print max/sample}' "${1}"
