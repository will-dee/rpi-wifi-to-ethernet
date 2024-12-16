#!/bin/bash

# Load wifi credentials from easy-to-modify file on the boot partition
# The file is of the form:
#
# SSID="your-network-name"
# PASSWORD="your-network-password"
#
# and can simply be sourced to bring these variables into our context.
CRED_FILE="/boot/wifi"
if [ ! -f $CRED_FILE ]; then
    echo "wifi credentials file $CRED_FILE is missing"
    exit 1
fi

source $CRED_FILE

# Check we have the required variables set now
if [ -z "$SSID" ] || [ -z "$PASSWORD" ]; then
    echo "SSID and PASSWORD must be set in $CRED_FILE"
    exit 1
fi

# Tell Raspbian to make the wifi be on
rfkill unblock wifi

CONNFILE=/etc/NetworkManager/system-connections/$SSID.nmconnection
  UUID=$(uuid -v4)
  cat <<- EOF >${CONNFILE}
	[connection]
	id=preconfigured
	uuid=${UUID}
	type=wifi
    autoconnect=true
	[wifi]
	mode=infrastructure
	ssid=${SSID}
	hidden=false
	[ipv4]
	method=auto
	[ipv6]
	addr-gen-mode=default
	method=auto
	[proxy]
    [wifi-security]
	key-mgmt=wpa-psk
	psk=${PASSWORD}
	EOF

  # NetworkManager will ignore nmconnection files with incorrect permissions,
  # to prevent Wi-Fi credentials accidentally being world-readable.
  chmod 600 ${CONNFILE}