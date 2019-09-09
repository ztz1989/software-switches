#!/bin/bash

rate=10000
size=64

r="$(bc <<< "scale=2; $rate/($size+20)/8")"

echo "$r"

