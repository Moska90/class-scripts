#!/bin/bash
# LRED="\e[91m"
# LGREEN="\e[92m"
# LYELLOW="\e[93m"
# LBLUE="\e[94m"
# LMAGENTA="\e[95m"
# LCYAN="\e[96m"
# LGREY="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

STDCOLOR=""
ERRCOLOR=""

LOGFILE="/var/log/install/$log.log"
ERRFILE="/var/log/install/error.log"

LOADED=(systemctl status kms | grep "Loaded")
ACTIVE=(systemctl status kms | grep "Active")

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
		echo -e "$ERRCOLOR"
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
read -p ">" script

mkdir /var/log/install

# GLPI
if [ $script == "0" ]; then
    log="glpi"
    clear
    intro

	echo -e "$LGREEN ------------------ $RESET"
	echo -e "$LGREEN Instalador de GLPI $RESET"
	echo -e "$LGREEN ------------------ $RESET"

	echo -e "$LGREEN De donde lo quieres instalar $RESET"
	declare -a web
	web=("172.31.0.5" "github")

	for i in ${!web[@]}; do
    	echo -e "$i) ${web[$i]}"
	done

	read -p ">" webserver

	echo -e "$LGREEN Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password

	echo -e "$LGREEN Instalando dependencias $RESET"
	apt-get update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y apache2 mariadb-server php php-mysql php-json php-fileinfo php-dom php-simplexml php-curl php-gd php-intl >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$LGREEN Instalando GLPI $RESET"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	test-err $?
	if [ $webserver == "0" ]; then
		wget 172.31.0.5/glpi/glpi.zip >>$LOGFILE 2>$ERRFILE
		test-err $?
		apt install -y unzip >>$LOGFILE 2>$ERRFILE
		test-err $?
		unzip glpi.zip >>$LOGFILE 2>$ERRFILE
		test-err $?
	elif [ $webserver == "1" ]; then
		wget https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz >>$LOGFILE 2>$ERRFILE
		test-err $?
		tar -xzvf glpi-10.0.7.tgz >>$LOGFILE 2>$ERRFILE
		test-err $?
	fi
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

	echo -e "$LGREEN ----------------------- $RESET"
	echo -e "$LGREEN Instalador de Wordpress $RESET"
	echo -e "$LGREEN ----------------------- $RESET"

	echo -e "$LGREEN De donde lo quieres instalar $RESET"
	declare -a web
	web=("172.31.0.5" "official website")

	for i in ${!web[@]}; do
    	echo -e "$i) ${web[$i]}"
	done

	read -p ">" webserver

	echo -e "$LGREEN Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password

	echo -e "$LGREEN Instalando dependencias $RESET"
	apt-get update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y apache2 mariadb-server php php-mysql >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$LGREEN Instalando Wordpress $RESET"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	if [ $webserver == "0" ]; then
		wget 172.31.0.5/wordpress/latest.tar.gz >>$LOGFILE 2>$ERRFILE
		test-err $?
		tar -xzvf latest.tar.gz >>$LOGFILE 2>$ERRFILE
		test-err $?
	elif [ $webserver == "1" ]; then
		wget https://wordpress.org/latest.zip >>$LOGFILE 2>$ERRFILE
		test-err $?
		apt install -y unzip >>$LOGFILE 2>$ERRFILE
		test-err $?
		unzip latest.zip >>$LOGFILE 2>$ERRFILE
		test-err $?
	fi
	mv wordpress/* /var/www/html/ >/var/log/install/wordpress.log 2>/var/log/install/error.log
	test-err $?

	echo -e "$LGREEN Dando permisos $RESET"
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

	echo -e "$LGREEN Reiniciando servidor $RESET"
	systemctl restart apache2
	test-err $?

	echo -e "$LGREEN Wordpress instalado $RESET"
	
	# echo -e "$LYELLOW Abre tu Wordpress en el navegador $RESET"

	# echo -e "$LGREY Usuario: $username $RESET"
	# echo -e "$LGREY Contraseña: $password $RESET"

	# echo -e "$LGREY Usuario: glpi $RESET"
	# echo -e "$LGREY Contraseña: glpi $RESET"

# KMS
elif [ $script == "2" ]; then
	log="KMS"
    clear
    intro

	echo -e "$BOLD$LGREEN Instalador de servidor KMS $RESET"
	apt update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt install -y unzip >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$BOLD$LGREEN Instalando archivos de KMS $RESET"
	wget https://github.com/Wind4/vlmcsd/archive/refs/heads/master.zip >>$LOGFILE 2>$ERRFILE
	test-err $?
	unzip master.zip >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$BOLD$LGREEN Ejecutando archivos de KMS $RESET"
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

	echo -e "$BOLD$LGREEN Preparando inicio de KMS $RESET"
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

	echo -e "$BOLD$LGREEN Reiniciando servicios $RESET"
	systemctl daemon-reload >>$LOGFILE 2>$ERRFILE
	systemctl start kms.service >>$LOGFILE 2>$ERRFILE
	systemctl enable kms.service >>$LOGFILE 2>$ERRFILE

	echo -e "$BOLD$LGREEN KMS listo $RESET"

	get_ip=$(ip a | grep "scope global dynamic" | tr -s " " | cut -d" " -f 3-3 | cut -d"/" -f 1-1)

	clear
	0intro

	echo -e "$BOLD$LGREY $LOADED $RESET"
	echo -e "$BOLD$LGREY $ACTIVE $RESET"

	echo -e "$BOLD$LGREY Para activar un windows haz: $RESET"
	echo -e "\t\t$BOLD$LGREY slmgr.vbs/skms [$get_ip] $RESET"
	echo -e "\t\t$BOLD$LGREY slmgr.vbs/ato $RESET"
	echo -e "$BOLD$LGREY Para comprovar que funciona: $RESET"
	echo -e "\t\t$BOLD$LGREY slmgr.vbs/dli $RESET"

# Moodle
elif [ $script == "3" ]; then
	log="moodle"
    clear
    intro

	echo -e "$LGREEN -------------------- $RESET"
	echo -e "$LGREEN Instalador de Moodle $RESET"
	echo -e "$LGREEN -------------------- $RESET"

	echo -e "$LGREEN Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password
	apt-get update >>$LOGFILE 2>$ERRFILE

	echo -e "$LGREEN Instalando dependencias $RESET"
	apt-get install -y apache2 mariadb-server >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y php php-mysql php-curl php-zip php-xml php-mbstring php-gd php-intl php-soap >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -r "$LGREEN Instalando Moodle $RESET"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	test-err $?
	wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.tgz >>$LOGFILE 2>$ERRFILE
	test-err $?
	tar zxvf moodle-latest-401.tgz >>$LOGFILE 2>$ERRFILE
	test-err $?
	mv moodle/* /var/www/html/ >>$LOGFILE 2>$ERRFILE
	test-err $?
	mkdir /var/www/moodledata >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$LGREEN Dando permisos $RESET"
	chown -R www-data:www-data /var/www/moodledata/ >>$LOGFILE 2>$ERRFILE
	test-err $?
	chown -R www-data:www-data /var/www/html/ >>$LOGFILE 2>$ERRFILE
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

	systemctl restart apache2 >>$LOGFILE 2>$ERRFILE

# Prestashop
elif [ $script == "3" ]; then
	log="prestashop"
    clear
    intro

	echo -e "$LGREEN ------------------ $RESET"
	echo -e "$LGREEN Instalador de GLPI $RESET"
	echo -e "$LGREEN ------------------ $RESET"

	echo -e "$LGREEN De donde lo quieres instalar $RESET"
	declare -a web
	web=("172.31.0.5" "github")

	for i in ${!web[@]}; do
    	echo -e "$i) ${web[$i]}"
	done

	read -p ">" webserver

	echo -e "$LGREEN Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$LGREEN Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$LGREEN Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password

	apt update
	apt install -y apache2 mariadb-server
	apt install -y php php-mysql php-intl php-zip php-xml php-curl php-gd php-mbstring unzip

	rm /var/www/html/index.htmlw

	wget https://www.prestashop.com/es/system/files/ps_releases/prestashop_1.7.7.2.zip >>$LOGFILE 2>$ERRFILE

	wget http://172.31.0.5//prestashop/prestashop_1.7.7.2.zip
	mv prestashop_1.7.7.2.zip /var/www/html
	cd /var/www/html
	unzip prestashop_1.7.7.2.zip
	unzip -o prestashop.zip

	echo -e "$LGREEN Dando permisos $RESET"
	chown -R www-data:www-data /var/www/html/*

	echo -e "$LGREEN Creando base de datos $RESET"
	mysql -u root -e "create database $database;"
	test-err $?
	mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
	test-err $?
	mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
	test-err $?
	mysql -u root -e "flush privileges;"
	test-err $?

	a2enmod rewrite
	systemctl restart apache2

fi