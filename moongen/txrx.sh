#!/bin/bash

MOONGEN=/usr/local/src/MoonGen/

if [[ -z "${1}" ]]
then
	SIZE=60
else
	SIZE="${1}"
fi

sudo "${MOONGEN}"/build/MoonGen txrx.lua 0 -s "${SIZE}"
