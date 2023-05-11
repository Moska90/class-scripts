#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GREY="\e[37m"
LRED="\e[91m"
LGREEN="\e[92m"
LYELLOW="\e[93m"
LBLUE="\e[94m"
LMAGENTA="\e[95m"
LCYAN="\e[96m"
LGREY="\e97m"
BOLD="\e[1m"
RESET="\e[0m"


echo -e "${LRED}Instalación de Moodle v.401 ${RESET}"
apt-get update >/dev/null 2>&1

echo -e "${LCYAN}Instalando dependencias de Moodle ${RESET}"
apt-get install -y apache2 mariadb-server >/dev/null 2>&1
apt-get install -y php php-mysql php-curl php-zip php-xml php-mbstring php-gd php-intl php-soap >/dev/null 2>&1

echo -r "${LCYAN}Instalando Moodle ${RESET}"
wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.tgz >/dev/null 2>&1
tar zxvf moodle-latest-401.tgz >/dev/null 2>&1
rm /var/www/html/index.html >/dev/null 2>&1
mv moodle/* /var/www/html/ >/dev/null 2>&1
mkdir /var/www/moodledata >/dev/null 2>&1

chown -R www-data:www-data /var/www/moodledata/ >/dev/null 2>&1
chown -R www-data:www-data /var/www/html/ >/dev/null 2>&1

mysql -u root -e "create user 'moodle'@'localhost' identified by 'moodle';" >/dev/null 2>&1
mysql -u root -e "create database moodle;" >/dev/null 2>&1
mysql -u root -e "grant all privileges on moodle.* to 'moodle'@'localhost';" >/dev/null 2>&1
mysql -u root -e "flush privileges;" >/dev/null 2>&1
mysql -u root -e "exit" >/dev/null 2>&1

systemctl restart apache2 >/dev/null 2>&1
