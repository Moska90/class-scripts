#!/bin/bash
LBLUE="\e[94m"
LMAGENTA="\e[95m"
BOLD="\e[1m"
RESET="\e[0m"

function test-err() {
	if [ $1 -ne 0 ]; then
		echo -e "$LMAGENTA"
		cat /var/log/install/error.log
		echo -e "$RESET"
		exit
	fi
}

clear

echo -e "$LBLUE Instalador de GLPI $RESET"

mkdir /var/log/install

echo -e "$LBLUE Instalando dependencias $RESET"
apt-get update >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
apt-get install -y apache2 mariadb-server php php-mysql php-json php-fileinfo php-dom php-simplexml php-curl php-gd php-intl >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?

echo -e "$LBLUE Instalando GLPI $RESET"
rm /var/www/html/index.html >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
wget http://172.31.0.5/glpi/glpi.zip >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
apt -y install unzip >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
unzip glpi.zip >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
mv glpi/* /var/www/html >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
rm glpi.zip >>/var/log/install/glpi.log 2>/var/log/install/error.log
rm -r glpi

echo -e "$LBLUE Creando base de datos $RESET"
mysql -u root -e "create database glpi;"
test-err $?
mysql -u root -e "create user 'alumnat'@'localhost' identified by 'alumnat';"
test-err $?
mysql -u root -e "grant all privileges on glpi.* to 'alumnat'@'localhost';"
test-err $?
mysql -u root -e "flush privileges;"
test-err $?

echo -e "$LBLUE Dando permisos $RESET"
chown -R www-data:www-data /var/www/html/* >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?
chmod -R 755 /var/www/html/* >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?

echo -e "$LBLUE Reiniciando servidor web $RESET"
systemctl restart apache2 >>/var/log/install/glpi.log 2>/var/log/install/error.log
test-err $?

echo -e "$LBLUE Abre tu GLPI en el navegador $RESET"