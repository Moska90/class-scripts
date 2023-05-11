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

function test-err() {
	if [ $1 -ne 0 ]; then
		exit
	fi
}

clear

echo -e "$LGREEN Instalador de GLPI $RESET"

echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
read username
echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
read password

echo -e "$LGREEN Instalando dependencias $RESET"
apt-get update >/dev/null 2>&1
test-err $?
apt-get install -y apache2 mariadb-server php php-mysql php-json php-fileinfo php-dom php-simplexml php-curl php-gd php-intl >/dev/null 2>&1
test-err $?

echo -e "$LGREEN Instalando GLPI $RESET"
rm /var/www/html/index.html >/dev/null 2>&1
test-err $?
wget https://github.com/glpi-project/glpi/releases/download/10.0.6/glpi-10.0.6.tgz >/dev/null 2>&1
test-err $?
tar xzvf glpi-10.0.6.tgz >/dev/null 2>&1
test-err $?
mv glpi/* /var/www/html >/dev/null 2>&1
test-err $?

echo -e "$LGREEN Creando base de datos $RESET"
mysql -u root -e "create database glpi;"
test-err $?
mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
test-err $?
mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
test-err $?
mysql -u root -e "flush privileges;"
test-err $?

echo -e "$LGREEN Dando permisos $RESET"
chown -R www-data:www-data /var/www/html/* >/dev/null 2>&1
test-err $?
chmod -R 755 /var/www/html/* >/dev/null 2>&1
test-err $?

echo -e "$LGREEN Reiniciando servidor web $RESET"
systemctl restart apache2 >/dev/null 2>&1
test-err $?

rm glpi-10.0.6.tgz
rm -r glpi

echo -e "$LYELLOW Abre tu GLPI en el navegador $RESET"

# localhost
# alumnat
# alumnat

# Cuenta
# glpi
# glpi