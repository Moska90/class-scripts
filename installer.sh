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

LOGFILE="/var/log/install/$log.log"
ERRFILE="/var/log/install/error.log"

clear

function intro(){
echo -e "$LIGHT$MAGENTA    //===============================================//$RESET"
echo -e "$LIGHT$MAGENTA   //=====$CYAN Creando scripts desde hace 2 dias $LIGHT$MAGENTA=======//$RESET"
echo -e "$LIGHT$MAGENTA  //============$CYAN GOLDNN ¬ MOSKA MAKEIT $LIGHT$MAGENTA ===========//$RESET"
echo -e "$LIGHT$MAGENTA //===============================================//$RESET"
echo -e "\r\r"  
}

intro

function isroot() {
	if [ $(whoami) != "root" ]; then
	echo -e "$LRED Necesitas root $RESET"
	exit 1
	fi
}

isroot

function test-err() {
	if [ $1 -ne 0 ]; then
		echo -e "$LMAGENTA"
		cat /var/log/install/error.log
		echo -e "$RESET"
		exit
	fi
}

declare -a myArray
myArray=("GLPI" "Wordpress" "KMS" "Moodle" "Prestashop")

for i in ${!myArray[@]}; do
    echo -e "$i) ${myArray[$i]}"
done

echo -e "Que quieres instalar"
read script

mkdir /var/log/install

# GLPI
if [ $script == "0" ]; then
    log="glpi"
    clear
    intro

# Wordpress
elif [ $script == "1" ]; then

# KMS
elif [ $script == "2" ]; then

# Moodle
elif [ $script == "3" ]; then

# Prestashop
elif [ $script == "3" ]; then

fi