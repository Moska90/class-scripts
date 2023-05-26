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

STDCOLOR="\e[92m"
ERRCOLOR="\e[91m"

LOGFILE="/var/log/kms/install.log"
ERRFILE="/var/log/kms/error.log"

LOCALE=$(locale | grep "LANG" | cut -d"=" -f2-)

function isroot() {
    if [ $(whoami) != "root" ]; then
        echo -e "$ERRCOLOR Necesitas root $RESET"
        exit 1
    fi
}

function test-err() {
    if [ $1 -ne 0 ]; then
        echo -e "$ERRCOLOR"
        cat $ERRFILE
        echo -e "$RESET"
        exit
    fi
}

echo -e "$BOLD$STDCOLOR Instalador de servidor KMS $RESET"
mkdir /var/log/kms/
apt update >>$LOGFILE 2>$ERRFILE
apt install -y unzip >>$LOGFILE 2>$ERRFILE
test-err $?

echo -e "$BOLD$STDCOLOR Instalando archivos de KMS $RESET"
wget https://github.com/Wind4/vlmcsd/archive/refs/heads/master.zip >>$LOGFILE 2>$ERRFILE
test-err $?
unzip master.zip >>$LOGFILE 2>$ERRFILE
test-err $?

echo -e "$BOLD$STDCOLOR Ejecutando archivos de KMS $RESET"
cd vlmcsd-master >>$LOGFILE 2>$ERRFILE
apt install -y gcc make cmake >>$LOGFILE 2>$ERRFILE
test-err $?
make >>$LOGFILE 2>$ERRFILE
test-err $?

cd bin >>$LOGFILE 2>$ERRFILE
mkdir /srv/kms >>$LOGFILE 2>$ERRFILE
test-err $?
cp vlmcsd /srv/kms >>$LOGFILE 2>$ERRFILE
test-err $?

echo -e "$BOLD$STDCOLOR Preparando inicio de KMS $RESET"
touch /etc/systemd/system/kms.service
test-err $?
chmod 755 /etc/systemd/system/kms.service
test-err $?

echo -e "" > /etc/systemd/system/kms.service
echo -e "[Unit]" >> /etc/systemd/system/kms.service
echo -e "After=network.target" >> /etc/systemd/system/kms.service
echo -e "[Service]" >> /etc/systemd/system/kms.service
echo -e "ExecStart=/srv/kms/vlmcsd" >> /etc/systemd/system/kms.service
echo -e "KillMode=mixed" >> /etc/systemd/system/kms.service
echo -e "RemainAfterExit=yes" >> /etc/systemd/system/kms.service
echo -e "[Install]" >> /etc/systemd/system/kms.service
echo -e "WantedBy=multi-user.target" >> /etc/systemd/system/kms.service

echo -e "$BOLD$STDCOLOR Reiniciando servicios $RESET"
systemctl daemon-reload >>$LOGFILE 2>$ERRFILE
test-err $?
systemctl start kms.service >>$LOGFILE 2>$ERRFILE
test-err $?
systemctl enable kms.service >>$LOGFILE 2>$ERRFILE
test-err $?

echo -e "$BOLD$STDCOLOR KMS listo $RESET"

get_ip=$(ip a | grep "scope global dynamic" | tr -s " " | cut -d" " -f 3-3 | cut -d"/" -f 1-1)

clear

echo -e "$BOLD$LGREY Para activar un windows haz: $RESET"
echo -e "\t\t$BOLD$LGREY slmgr.vbs/skms [$get_ip] $RESET"
echo -e "\t\t$BOLD$LGREY slmgr.vbs/ato $RESET"
echo -e "$BOLD$LGREY Para comprovar que funciona: $RESET"
echo -e "\t\t$BOLD$LGREY slmgr.vbs/dli $RESET"