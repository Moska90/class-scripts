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

	echo -e "$LGREEN Instalador de GLPI $RESET"

	echo -e "$LGREEN De donde lo quieres instalar $RESET"
	read wget

	echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
	read -p > username
	echo -e "$LGREEN Que nombre quieres para tu base de datos $RESET"
	read -p > database
	echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
	read -p > password

	echo -e "$LGREEN Instalando dependencias $RESET"
	apt-get update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y apache2 mariadb-server php php-mysql php-json php-fileinfo php-dom php-simplexml php-curl php-gd php-intl >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$LGREEN Instalando GLPI $RESET"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	test-err $?
	wget $wget >>$LOGFILE 2>$ERRFILE
	test-err $?
	tar xzvf glpi-10.0.6.tgz >>$LOGFILE 2>$ERRFILE
	test-err $?
	mv glpi/* /var/www/html >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$LGREEN Creando base de datos $RESET"
	mysql -u root -e "create database $database;"
	test-err $?
	mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
	test-err $?
	mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
	test-err $?
	mysql -u root -e "flush privileges;"
	test-err $?

	echo -e "$LGREEN Dando permisos $RESET"
	chown -R www-data:www-data /var/www/html/* >>$LOGFILE 2>$ERRFILE
	test-err $?
	chmod -R 755 /var/www/html/* >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$LGREEN Reiniciando servidor web $RESET"
	systemctl restart apache2 >>$LOGFILE 2>$ERRFILE
	test-err $?

	rm glpi-10.0.6.tgz
	rm -r glpi

	echo -e "$LYELLOW Abre tu GLPI en el navegador $RESET"

	echo -e "$LGREY Base de datos: localhost $RESET"
	echo -e "$LGREY Usuario: $username $RESET"
	echo -e "$LGREY Contraseña: $password $RESET"

	echo -e "$LGREY Usuario: glpi $RESET"
	echo -e "$LGREY Contraseña: glpi $RESET"

# Wordpress
elif [ $script == "1" ]; then
	log="wordpress"
    clear
    intro

	echo -e "${GREEN}Preparando instalación de Wordpress ${RESET}"

	echo -e "$LGREEN De donde lo quieres instalar $RESET"
	read wget

	echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
	read -p > username
	echo -e "$LGREEN Que nombre quieres para tu base de datos $RESET"
	read -p > database
	echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
	read -p > password

	echo -e "${GREEN}Instalando dependencias ${RESET}"
	apt-get update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y apache2 mariadb-server >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y php php-mysql >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "${GREEN}Instalando Wordpress ${RESET}"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	test-err $?
	wget 172.31.0.1/wordpress/latest.tar.gz >>$LOGFILE 2>$ERRFILE
	test-err $?
	tar -xzvf  >>$LOGFILE 2>$ERRFILE
	test-err $?
	mv wordpress/* /var/www/html/ >/var/log/install/wordpress.log 2>/var/log/install/error.log
	test-err $?
	chown -R www-data:www-data /var/www/html >/var/log/install/wordpress.log 2>/var/log/install/error.log
	test-err $?

	echo -e "$LGREEN Creando base de datos $RESET"
	mysql -u root -e "create database $database;"
	test-err $?
	mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
	test-err $?
	mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
	test-err $?
	mysql -u root -e "flush privileges;"
	test-err $?

	echo -e "${GREEN}Reiniciando servidor ${RESET}"
	systemctl restart apache2
	test-err $?

	echo -e "${GREEN}Wordpress instalado ${RESET}"
	echo -e "${GREEN}Ya puedes abrir el servidor en el navegador ${RESET}"

# KMS
elif [ $script == "2" ]; then
	log="KMS"
    clear
    intro

# Moodle
elif [ $script == "3" ]; then
	log="moodle"
    clear
    intro

# Prestashop
elif [ $script == "3" ]; then
	log="prestashop"
    clear
    intro

fi