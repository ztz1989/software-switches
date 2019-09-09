#!/bin/bash

CUR_DIR=$(pwd)
cd ${CLICKNF_DIR}

if [[ -z "${1}" ]]
then
	config="unidirectional-x.click"
else
	config="${1}"
fi

echo "APP: ${config}"
sudo bin/click --dpdk -c0x600 -w "0000:0b:00.0" -w "0000:0b:00.1" --socket-mem=2048,0 -- ${CUR_DIR}/${config}
