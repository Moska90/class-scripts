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

LOCALE=$(locale | grep "LANG" | cut -d"=" -f2-)

if [ $LOCALE == es_ES.UTF-8 ]
	then
		CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f4-)
elif [ $LOCALE == en_UE.UTF-8 ]
	then 
		CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f3-)
fi

CORES=$(lscpu | grep "Núcleo(s) por «socket»:" | tr -s " " | cut -d" " -f4-)
THREADS=$(lscpu | grep "CPU(s):" | grep -v "NUMA" | tr -s " " | cut -d" " -f2-)
RAM=$(dmidecode --type memory | grep "Size:" | grep -v "No" | grep -v "Volatile" | cut -d" " -f2 |  paste -sd+ | bc)
RAM_TYPE=$(dmidecode --type memory | grep "Type:" | grep -v "Error" | grep -v "Unknown" | cut -d" " -f2 | uniq)
VGA=$(lspci | grep "VGA" | cut -d" " -f5-)
MOTHERBOARD=$(dmidecode --type system | grep "Product" | cut -d" " -f3-)

clear

echo -e "$LRED-----------------------------$RESET"
echo -e "$STDCOLOR Información sobre la CPU$RESET"
echo -e "Procesador:\t${CPU_NAME}"
echo -e "Nucleos:\t${CORES}"
echo -e "Hilos:\t\t${THREADS}"
echo -e "$LRED-----------------------------$RESET"

echo -e "$STDCOLOR Información sobre la RAM$RESET"
echo -e "Cantidad:\t\t${RAM} GB"
echo -e "Tipo:\t${RAM_TYPE}"
echo -e "$LRED-----------------------------$RESET"

echo -e "$STDCOLOR Información sobre la gráfica$RESET"
echo -e "Gráfica:\t${VGA}"
echo -e "Placa base:\t${MOTHERBOARD}"
echo -e "$LRED-----------------------------$RESET"