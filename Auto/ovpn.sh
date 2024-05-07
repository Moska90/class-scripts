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
FILES_DIR=/root/files/
OUTPUT_DIR=/root/ovpn/
BASE_CONF=/root/files/client.conf

# Function for checks
function pwdeasyrsa() {
	if [[ $(pwd) != */EasyRSA* ]]; then
		echo -e "$LRED Run the script from the EasyRSA directory$RESET"
		exit 1
	else
		echo -e "$LGREEN Continuing with the script$RESET"
	fi
}

pwdeasyrsa

# Basic questions for file names
echo -e "$LCYAN What's the name of the client?$RESET"
read -p " >" client

# Cert and key creation for client
./easyrsa gen-req $client nopass <<EOF
$client
EOF

./easyrsa sign-req client $client <<EOF
yes
EOF

mv pki/private/$client.key $FILES_DIR
mv pki/reqs/$client.req $FILES_DIR
mv pki/issued/$client.crt $FILES_DIR

# .ovpn creation for client
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${FILES_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${FILES_DIR}/$client.crt \
    <(echo -e '</cert>\n<key>') \
    ${FILES_DIR}/$client.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${FILES_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}${client}.ovpn
