#!/bin/bash

NET_ADAPTER="eth0"
IP_ADDR="192.168.123.1/24"

# Flush all addresses that might be on the adapter
ip link set dev "$NET_ADAPTER" down
ip addr flush "$NET_ADAPTER"

# Add a new IP address
ip addr add "$IP_ADDR" dev "$NET_ADAPTER"
ip link set dev "$NET_ADAPTER" up