#!/bin/bash

echo 'net.inet.ip.forwarding=1' >>/etc/sysctl.conf
sysctl net.inet.ip.forwarding=1

SOURCE_IP=$(curl -s ipinfo.io/ip)

cat >>/etc/pf.conf <<EOF
# pf.conf
# port=${WG_PORT}

# martians should never be external source address
table <martians> { 0.0.0.0/8 127.0.0.0/8 169.254.0.0/16 10.0.0.0/8 
                   172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 224.0.0.0/3 
                   198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 }
vpn = "wg0"

set block-policy drop
set loginterface egress
set skip on lo0

match in all scrub (no-df random-id max-mss 1440)
match out on egress inet from !(egress:network) to any nat-to (egress:0)

antispoof quick for egress

block in quick on egress from <martians> to any
block return out quick on egress from any to <martians>

block all

# allow outgoing traffic
pass out quick inet

# allow SSH connection attempts from VPN clients
pass in on egress inet proto tcp from ${SOURCE_IP} to (egress) port 22
pass in on vpn inet proto tcp from any to (egress) port 22

# allow DNS responses from Internet
pass in on egress proto { udp tcp } from any to (egress) port 53

# allow wireguard client connections
pass in on egress proto udp from any to (egress) port 51820

# allow wireguard peer-to-peer traffic
pass on vpn
EOF

pfctl -d
pfctl -F all
pfctl -f /etc/pf.conf
pfctl -e

rcctl stop smtpd
rcctl disable smtpd

# - modify unbound.conf to listen and allow DNS client connections on wg0 network
cat>EDITS <<EOF
/.*interface: 127.0.0.1$/ a\\
        interface: 10.10.${WG_NETWORK}.1
;
/.*access-control: 0.0.0.0\/0 refuse$/ a\\
	access-control: 10.10.${WG_NETWORK}.0/24 allow
;
EOF
sed -f EDITS unbound.conf

rcctl enable unbound
rcctl start unbound
