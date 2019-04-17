#!/bin/bash

awk -v max=0 '{max+=$2}END{print max}' "${1}"
