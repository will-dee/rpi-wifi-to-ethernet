#!/bin/bash

dnsmasq \
    --interface=eth0 \
    --bind-dynamic \
    --no-daemon \
    --domain=pifi \
    --dhcp-range=192.168.123.10,192.168.123.100,1h \
    --dhcp-authoritative