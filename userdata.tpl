#!/bin/bash

apt update ; \
apt install -y \
	docker.io \
	make \
	jq \
	qemu-system \
	build-essential \
	git \
	virtualbox

sudo ip link add br0 type bridge && \
sudo ip addr add 192.168.100.50/24 brd 192.168.100.255 dev br0 && \
sudo ip tuntap add mode tap user $(whoami) && \
ip tuntap show && \
sudo ip link set tap0 master br0 && \
sudo ip link set dev br0 up && \
sudo ip link set dev tap0 up && \
sudo dnsmasq --interface=br0 --bind-interfaces \
    --dhcp-range=192.168.100.50,192.168.100.254

cat > /root/USAGE_QEMU.md <<EOF

To use the tap interface with a qemu guest:

\`\`\`bash
qemu -device e1000,netdev=network0,mac=00:00:00:00:00:00 \
        -netdev tap,id=network0,ifname=tap0,script=no,downscript=no
\`\`\`

In the guest system assign static IP address to the network interface:

\`\`\`bash
ip addr add 192.168.100.224/24 broadcast 192.168.100.255 dev eth0
\`\`\`
EOF
