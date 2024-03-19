#!/bin/bash

KEY_DIR=/etc/openvpn/client
OUTPUT_DIR=/etc/openvpn/client
BASE_CONFIG=/etc/openvpn/client/client.conf

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
