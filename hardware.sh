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

ERRFILE="/var/log/install/error.log"

LOCALE=$(locale | grep "LANG" | cut -d"=" -f2-)

function isroot() {
	if [ $(whoami) != "root" ]; then
	echo -e "$ERRCOLOR Necesitas root $RESET"
	exit 1
	fi
}

isroot

function test-err() {
	if [ $1 -ne 0 ]; then
		echo -e "$ERRCOLOR"
		cat /var/log/install/error.log
		echo -e "$RESET"
		exit
	fi
}

LOCALE=$(locale | grep "LANG" | cut -d"=" -f2-)

if [ $LOCALE == es_ES.UTF-8 ]
then
    CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f4-)
elif [ $LOCALE == en_UE.UTF-8 ]
then
    CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f3-)
fi

LOGFILE="/var/log/install/hardware.log"
clear

apt install -y bc >>$LOGFILE 2>$ERRFILE

if [ $LOCALE == es_ES.UTF-8 ]; then
    CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f4-)
    elif [ $LOCALE == en_UE.UTF-8 ]; then
    CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f3-)
fi

CORES=$(lscpu | grep "Núcleo(s) por «socket»:" | tr -s " " | cut -d" " -f4-)
THREADS=$(lscpu | grep "CPU(s):" | grep -v "NUMA" | tr -s " " | cut -d" " -f2-)
RAM=$(dmidecode --type memory | grep "Size:" | grep -v "No" | grep -v "Volatile" | cut -d" " -f2 |  paste -sd+ | bc)
RAM_TYPE=$(dmidecode --type memory | grep "Type:" | grep -v "Error" | grep -v "Unknown" | cut -d" " -f2 | uniq)
MODULS=$(dmidecode --type memory | grep "Devices" | cut -d" " -f4)

echo -e "Marca i model de CPU: ${CPU_NAME}"
echo -e "Número de nuclis de CPU: ${CORES}"
echo -e "Número de fils d'execució per nucli de CPU: ${THREADS}"
echo -e "Memòria RAM total instalada: ${RAM} GB"
echo -e "Tipus de memòria RAM: ${RAM_TYPE}"
echo -e "Número de mòduls de RAM instal·lats: $MODULS"