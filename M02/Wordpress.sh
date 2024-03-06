#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

function test-err() {
	if [ $1 -ne 0 ]; then
		echo -e "${RED}"
		cat /var/log/install/error.log
		echo -e "${RESET}"
		exit
	fi
}

clear

echo -e "${GREEN}Preparando instalación de Wordpress ${RESET}"

echo -e "${GREEN}Instalando dependencias ${RESET}"
apt-get update >>$LOGFILE 2>$ERRFILE
test-err $?
apt-get install -y apache2 mariadb-server >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
apt-get install -y php php-mysql >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?

echo -e "${GREEN}Instalando Wordpress ${RESET}"
rm /var/www/html/index.html >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
wget 172.31.0.1/wordpress/latest.tar.gz >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
tar -xzvf  >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
mv wordpress/* /var/www/html/ >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
chown -R www-data:www-data /var/www/html >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?

echo -e "${GREEN}Creando base de datos ${RESET}"
mysql -u root -e "create database wordpress;" >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
mysql -u root -e "create user 'wordpress'@'localhost' identified by 'wordpress';" >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
mysql -u root -e "grant all privileges on wordpress.* to 'wordpress'@'localhost';" >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err 
mysql -u root -e "flush privileges;" >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?
mysql -u root -e "exit" >/var/log/install/wordpress.log 2>/var/log/install/error.log
test-err $?

echo -e "${GREEN}Reiniciando servidor ${RESET}"
systemctl restart apache2
test-err $?

echo -e "${GREEN}Wordpress instalado ${RESET}"
echo -e "${GREEN}Ya puedes abrir el servidor en el navegador ${RESET}"
