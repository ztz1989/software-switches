#!/bin/bash

awk -v max=0 -F',' '{max+=$2}END{print max}' "${1}"
