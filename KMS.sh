#!/bin/bash

GREY="\e[37m"
LRED="\e[91m"
LGREEN="\e[92m"
LYELLOW="\e[93m"
LBLUE="\e[94m"
LMAGENTA="\e[95m"
LCYAN="\e[96m"
LGREY="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

echo -e "$BOLD$LMAGENTA Instalador de servidor KMS $RESET"
clear
apt update >/dev/null 2>&1
apt install -y unzip >/dev/null 2>&1

echo -e "$BOLD$LMAGENTA Instalando archivos de KMS $RESET"
wget https://github.com/Wind4/vlmcsd/archive/refs/heads/master.zip >/dev/null 2>&1
unzip master.zip >/dev/null 2>&1

echo -e "$BOLD$LMAGENTA Ejecutando archivos de KMS $RESET"
cd vlmcsd-master >/dev/null 2>&1
apt install -y gcc make cmake >/dev/null 2>&1
make >/dev/null 2>&1

cd bin >/dev/null 2>&1
mkdir /srv/kms >/dev/null 2>&1
cp vlmcsd /srv/kms >/dev/null 2>&1

echo -e "$BOLD$LMAGENTA Preparando inicio de KMS $RESET"
touch /etc/systemd/system/kms.service
chmod 755 /etc/systemd/system/kms.service

echo -e "" > /etc/systemd/system/kms.service
echo -e "[Unit]" >> /etc/systemd/system/kms.service
echo -e "After=network.target" >> /etc/systemd/system/kms.service
echo -e "[Service]" >> /etc/systemd/system/kms.service
echo -e "ExecStart=/srv/kms/vlmcsd" >> /etc/systemd/system/kms.service
echo -e "KillMode=mixed" >> /etc/systemd/system/kms.service
echo -e "RemainAfterExit=yes" >> /etc/systemd/system/kms.service
echo -e "[Install]" >> /etc/systemd/system/kms.service
echo -e "WantedBy=multi-user.target" >> /etc/systemd/system/kms.service

echo -e "$BOLD$LMAGENTA Reiniciando servicios $RESET"
systemctl daemon-reload >/dev/null 2>&1
systemctl start kms.service >/dev/null 2>&1
systemctl enable kms.service >/dev/null 2>&1

echo -e "$BOLD$LMAGENTA KMS listo $RESET"

get_ip=$(ip a | grep "scope global dynamic" | tr -s " " | cut -d" " -f 3-3 | cut -d"/" -f 1-1)

echo -e "$BOLD$GREY Para activar un windows haz: $RESET"
echo -e "\t\t$BOLD$GREY slmgr.vbs/skms [$get_ip] $RESET"
echo -e "\t\t$BOLD$GREY slmgr.vbs/ato $RESET"
echo -e "$BOLD$GREY Para comprovar que funciona: $RESET"
echo -e "\t\t$BOLD$GREY slmgr.vbs/dli $RESET"