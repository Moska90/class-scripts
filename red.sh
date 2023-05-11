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

function test-ping() {
	if [ $1 -ne 0 ]; then
        echo -e "$LCYAN  Conexion: \t$LRED     Error $RESET"
        echo -e "\n"
        echo -e "$LMAGENTA -------------------------------- $RESET"
        exit
    else
        echo -e "$LCYAN  Conexion: \t$LGREEN     OK $RESET"
fi
}

get_ip=$(ip a | grep "scope global dynamic" | tr -s " " | cut -d" " -f 3-3)
get_gw=$(ip r | grep "default via" | tr -s " " | cut -d" " -f 3-3)
get_dns=$(cat /etc/resolv.conf | grep "nameserver" | cut -d" " -f 2-2)

clear

echo -e "$LMAGENTA -------------------------------- $RESET"
echo -e "$LCYAN  Tu IP es:$RESET \t ${get_ip}"
echo -e "$LCYAN  Tu GW es:$RESET \t ${get_gw}"
echo -e "$LCYAN  Tu DNS es:$RESET \t ${get_dns}"
echo -e "$LMAGENTA -------------------------------- $RESET"
echo -e "\n"

ping -c 1 google.com > /dev/null 2>&1
test-ping $?

echo -e "\n"
echo -e "$LMAGENTA -------------------------------- $RESET"