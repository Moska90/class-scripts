#!/bin/bash
LRED="\e[91m"
LGREEN="\e[92m"
LYELLOW="\e[93m"
LBLUE="\e[94m"
LMAGENTA="\e[95m"
LCYAN="\e[96m"
LGREY="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

STDCOLOR="\e[96m"
ERRCOLOR="\e[91m"

# Directories for .ovpn files
KEY_DIR=/etc/openvpn/client
OUTPUT_DIR=/etc/openvpn/client
BASE_CONFIG=/etc/openvpn/client/client.conf

# Function for checks
function pwdeasyrsa() {
	if [[ $(pwd) != */EasyRSA* ]]; then
		echo -e "$LRED Run the script from the EasyRSA directory$RESET"
		exit 1
	else
		echo -e "$LGREEN Continuing with the script$RESET"
	fi
}

# Cert and key creation for client

pwdeasyrsa

# .ovpn creation for client
cat $BASE_CONFIG \
	<(echo -e '<ca>') \
	$KEY_DIR/ca.crt				
	<(echo -e '</ca>\n<cert>') \
	$KEY_DIR/client.crt
	<(echo -e '</cert>\n<key>') \
	$KEY_DIR/client.key
	<(echo -e '</key>\n<tls-crypt>') \
	$KEY_DIR/ta.key
	<(echo -e '</tls-crypt>') \
	> $OUTPUT_DIR/$1.ovpn
