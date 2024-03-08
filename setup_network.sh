#!/bin/bash

# Setup sysctl config
sysctl -w "net.ipv6.conf.all.disable_ipv6 = 0"
sysctl -w "net.ipv6.conf.all.disable_ipv6 = 0"
sysctl -w "net.ipv6.conf.default.disable_ipv6 = 0"
sysctl -w "net.ipv6.conf.lo.disable_ipv6 = 0"

# Setup Network
ip route add 127.0.0.1/8 dev lo
ip route add 10.0.0.0/8 dev eth0
ip route add 172.16.0.0/12 dev eth0
ip route add 192.168.0.0/16 dev eth0
ip route add 169.254.0.0/16 dev eth0
ip route add ::1/128 dev lo
ip route add fc00::/7 dev eth0
ip route add fe80::/10 dev eth0
ip route add ::ffff:7f00:1/104 dev lo
ip route add ::ffff:a00:0/104 dev eth0
ip route add ::ffff:a9fe:0/112 dev eth0
ip route add ::ffff:ac10:0/108 dev eth0
ip route add ::ffff:c0a8:0/112 dev eth0

# Keep container running
tail -f /dev/null
