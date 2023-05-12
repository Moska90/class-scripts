#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GREY="\e[37m"
BOLD="\e[1m"
RESET="\e[0m"

function intro(){
echo -e "$BOLD$MAGENTA    //===============================================//$RESET"
echo -e "$BOLD$MAGENTA   //=====$CYAN Creando scripts desde hace 2 dias $BOLD$MAGENTA=======//$RESET"
echo -e "$BOLD$MAGENTA  //============$CYAN GOLDNN ¬ MOSKA MAKEIT $BOLD$MAGENTA ===========//$RESET"
echo -e "$BOLD$MAGENTA //===============================================//$RESET"
echo -e "\r\r"  
}

clear

intro

ip a | grep "state UP" | tr -s " " | cut -d":" -f2-2 >> int.log 2>&1

declare -a myArray
myArray=(`cat "int.log"`)

for i in ${!myArray[@]}; do
    echo -e "$i) ${myArray[$i]}"
done

rm int.log

read iw_name

for i in ${!myArray[@]}; do
    if [ $iw_name == $i ]; then
        get_int=${myArray[$i]}
    fi
done

while true; do
        clear
        intro
        iwconfig $get_int | grep "ESSID" | tr -s " " |cut -d" " -f4-
        iwconfig $get_int | grep "Frequency" | tr -s " " 
        iwconfig $get_int | grep "Link" | tr -s " " 
        sleep 0.4
done