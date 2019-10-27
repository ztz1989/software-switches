FROM ubuntu:16.04
COPY ./dpdk-stable-18.11.2 /root/dpdk
COPY ./pktgen-19.10.0 /root/pktgen-19.10.0
COPY ./FloWatcher-DPDK /root/FloWatcher-DPDK
COPY ./build_dpdk.sh /root/scripts/
WORKDIR /root/scripts
RUN apt-get update && apt-get install -y build-essential automake python-pip libcap-ng-dev gawk pciutils nano kmod libnuma-dev linux-headers-$(uname -r) lua5.3 liblua5.3-dev libpcap-dev
RUN pip install -U pip six
ENV DPDK_DIR "/root/dpdk"
ENV DPDK_BUILD "x86_64-native-linuxapp-gcc"
ENV RTE_SDK "/root/dpdk"
ENV RTE_TARGET "x86_64-native-linuxapp-gcc"
RUN ./build_dpdk.sh
WORKDIR /root/FloWatcher-DPDK
RUN make -j40
WORKDIR /root/pktgen-19.10.0
RUN make -j40
WORKDIR /root
CMD ["/bin/bash"]
