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

LOGFILE="/var/log/install/$log.log"
ERRFILE="/var/log/install/error.log"

LOADED=(systemctl status kms | grep "Loaded")
ACTIVE=(systemctl status kms | grep "Active")

LOCALE=$(locale | grep "LANG" | cut -d"=" -f2-)

function intro(){
	echo -e "$BOLD$LMAGENTA    //===============================================//$RESET"
	echo -e "$BOLD$LMAGENTA   //=====$LCYAN Creando scripts desde hace 2 dias $BOLD$LMAGENTA=======//$RESET"
	echo -e "$BOLD$LMAGENTA  //============$LCYAN GOLDNN ¬ MOSKA MAKEIT $BOLD$LMAGENTA ===========//$RESET"
	echo -e "$BOLD$LMAGENTA //===============================================//$RESET"
	echo -e "\r\r"  
}

function isroot() {
	if [ $(whoami) != "root" ]; then
	echo -e "$ERRCOLOR Necesitas root $RESET"
	exit 1
	fi
}

function test-err() {
	if [ $1 -ne 0 ]; then
		echo -e "$ERRCOLOR"
		cat /var/log/install/error.log
		echo -e "$RESET"
		exit
	fi
}

function internet() {
	if [ $1 -ne 0 ]; then
        echo -e "$ERRCOLOR Necesitas conexión a internet $RESET"
        exit
	fi
}

function test-ping() {
	if [ $1 -ne 0 ]; then
        echo -e "$STDCOLOR  Conexion: \t$LRED     Error $RESET"
        echo -e "\n"
        echo -e "$STDCOLOR -------------------------------- $RESET"
        exit
    else
        echo -e "$STDCOLORN  Conexion: \t$LGREEN     OK $RESET"
fi
}

clear
intro
isroot
ping -c 1 google.com >>$LOGFILE 2>$ERRFILE
internet $?

# List for chosing what to do
declare -a what
what=("Install" "Red" "Hardware")

for i in ${!what[@]}; do
	echo -e "$i) ${what[$i]}"
done

echo -e "Que quieres hacer"
read -p ">" hacer

# List for chosing what to install
declare -a scripts
scripts=("GLPI" "Wordpress" "KMS" "Moodle" "Prestashop")

# Install
if [ $hacer = "0" ]; then
    for i in ${!scripts[@]}; do
    	echo -e "$i) ${scripts[$i]}"
	done
	echo -e "Que quieres instalar"
	read -p ">" script
# Red
elif [ $hacer = "1" ]; then
	log="red"
    clear
    intro

	get_ip=$(ip a | grep "scope global dynamic" | tr -s " " | cut -d" " -f 3-3)
	get_gw=$(ip r | grep "default via" | tr -s " " | cut -d" " -f 3-3)
	get_dns=$(cat /etc/resolv.conf | grep "nameserver" | cut -d" " -f 2-2)

	echo -e "$LMAGENTA -------------------------------- $RESET"
	echo -e "$LCYAN  Tu IP es:$RESET \t ${get_ip}"
	echo -e "$LCYAN  Tu GW es:$RESET \t ${get_gw}"
	echo -e "$LCYAN  Tu DNS es:$RESET \t ${get_dns}"
	echo -e "$LMAGENTA -------------------------------- $RESET"
	echo -e "\n"

	ping -c 1 google.com >>$LOGFILE 2>$ERRFILE
	test-ping $?

	echo -e "\n"
	echo -e "$LMAGENTA -------------------------------- $RESET"
# Hardware
elif [ $hacer = "2" ]; then
	log="hardware"
    clear
    intro

	if [ $LOCALE == es_ES.UTF-8 ]; then
		CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f4-)
	elif [ $LOCALE == en_UE.UTF-8 ]; then 
		CPU_NAME=$(lscpu | grep "Nombre del modelo" | tr -s " " | cut -d" " -f3-)
	fi

	CORES=$(lscpu | grep "Núcleo(s) por «socket»:" | tr -s " " | cut -d" " -f4-)
	THREADS=$(lscpu | grep "CPU(s):" | grep -v "NUMA" | tr -s " " | cut -d" " -f2-)
	RAM=$(dmidecode --type memory | grep "Size:" | grep -v "No" | grep -v "Volatile" | cut -d" " -f2 |  paste -sd+ | bc)
	RAM_TYPE=$(dmidecode --type memory | grep "Type:" | grep -v "Error" | grep -v "Unknown" | cut -d" " -f2 | uniq)
	VGA=$(lspci | grep "VGA" | cut -d" " -f5-)
	MOTHERBOARD=$(dmidecode --type system | grep "Product" | cut -d" " -f3-)

	echo -e "$LRED-----------------------------$RESET"
	echo -e "$STDCOLOR Información sobre la CPU$RESET"
	echo -e "Procesador:\t${CPU_NAME}"
	echo -e "Nucleos:\t${CORES}"
	echo -e "Hilos:\t\t${THREADS}"
	echo -e "$LRED-----------------------------$RESET"

	echo -e "$STDCOLOR Información sobre la RAM$RESET"
	echo -e "Cantidad:\t\t${RAM} GB"
	echo -e "Tipo:\t${RAM_TYPE}"
	echo -e "$LRED-----------------------------$RESET"

	echo -e "$STDCOLOR Información sobre la gráfica$RESET"
	echo -e "Gráfica:\t${VGA}"
	echo -e "Placa base:\t${MOTHERBOARD}"
	echo -e "$LRED-----------------------------$RESET"
done

mkdir /var/log/install

# GLPI
if [ $script == "0" ]; then
    log="glpi"
    clear
    intro

	echo -e "$STDCOLOR ------------------ $RESET"
	echo -e "$STDCOLOR Instalador de GLPI $RESET"
	echo -e "$STDCOLOR ------------------ $RESET"

	echo -e "$STDCOLOR De donde lo quieres instalar $RESET"
	declare -a web
	web=("172.31.0.5" "github")

	for i in ${!web[@]}; do
    	echo -e "$i) ${web[$i]}"
	done

	read -p ">" webserver

	echo -e "$STDCOLOR Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$STDCOLOR Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$STDCOLOR Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password

	echo -e "$STDCOLOR Instalando dependencias $RESET"
	apt-get update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y apache2 mariadb-server php php-mysql php-json php-fileinfo php-dom php-simplexml php-curl php-gd php-intl >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$STDCOLOR Instalando GLPI $RESET"
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

	echo -e "$STDCOLOR Creando base de datos $RESET"
	mysql -u root -e "create database $database;"
	test-err $?
	mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
	test-err $?
	mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
	test-err $?
	mysql -u root -e "flush privileges;"
	test-err $?

	echo -e "$STDCOLOR Dando permisos $RESET"
	chown -R www-data:www-data /var/www/html/* >>$LOGFILE 2>$ERRFILE
	test-err $?
	chmod -R 755 /var/www/html/* >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$STDCOLOR Reiniciando servidor web $RESET"
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

	echo -e "$STDCOLOR ----------------------- $RESET"
	echo -e "$STDCOLOR Instalador de Wordpress $RESET"
	echo -e "$STDCOLOR ----------------------- $RESET"

	echo -e "$STDCOLOR De donde lo quieres instalar $RESET"
	declare -a web
	web=("172.31.0.5" "official website")

	for i in ${!web[@]}; do
    	echo -e "$i) ${web[$i]}"
	done

	read -p ">" webserver

	echo -e "$STDCOLOR Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$STDCOLOR Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$STDCOLOR Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password

	echo -e "$STDCOLOR Instalando dependencias $RESET"
	apt update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt install -y apache2 mariadb-server 
	apt install -y php php-mysql php-curl php-zip php-xml php-bz2 php-mbstring php-gd php-intl php-xmlrpc php-soap php-ldap >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$STDCOLOR Instalando Wordpress $RESET"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	if [ $webserver == "0" ]; then
		wget 172.31.0.5/wordpress/latest.tar.gz >>$LOGFILE 2>$ERRFILE
		test-err $?
	elif [ $webserver == "1" ]; then
		wget https://wordpress.org/latest.tar.gz >>$LOGFILE 2>$ERRFILE
		test-err $?
	fi
	tar -xzvf latest.tar.gz >>$LOGFILE 2>$ERRFILE
	test-err $?
	mv wordpress/* /var/www/html/ >/var/log/install/wordpress.log 2>/var/log/install/error.log
	test-err $?

	echo -e "$STDCOLOR Dando permisos $RESET"
	chown -R www-data:www-data /var/www/html >/var/log/install/wordpress.log 2>/var/log/install/error.log
	test-err $?

	echo -e "$STDCOLOR Creando base de datos $RESET"
	mysql -u root -e "create database $database;"
	test-err $?
	mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
	test-err $?
	mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
	test-err $?
	mysql -u root -e "flush privileges;"
	test-err $?

	echo -e "$STDCOLOR Reiniciando servidor $RESET"
	systemctl restart apache2
	test-err $?

	echo -e "$STDCOLOR Wordpress instalado $RESET"
	
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

	echo -e "$BOLD$STDCOLOR Instalador de servidor KMS $RESET"
	apt update >>$LOGFILE 2>$ERRFILE
	test-err $?
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
	systemctl start kms.service >>$LOGFILE 2>$ERRFILE
	systemctl enable kms.service >>$LOGFILE 2>$ERRFILE

	echo -e "$BOLD$STDCOLOR KMS listo $RESET"

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

	echo -e "$STDCOLOR -------------------- $RESET"
	echo -e "$STDCOLOR Instalador de Moodle $RESET"
	echo -e "$STDCOLOR -------------------- $RESET"

	echo -e "$STDCOLOR Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$STDCOLOR Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$STDCOLOR Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password
	apt-get update >>$LOGFILE 2>$ERRFILE

	echo -e "$STDCOLOR Instalando dependencias $RESET"
	apt-get install -y apache2 mariadb-server >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt-get install -y php php-mysql php-curl php-zip php-xml php-mbstring php-gd php-intl php-soap >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -r "$STDCOLOR Instalando Moodle $RESET"
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

	echo -e "$STDCOLOR Dando permisos $RESET"
	chown -R www-data:www-data /var/www/moodledata/ >>$LOGFILE 2>$ERRFILE
	test-err $?
	chown -R www-data:www-data /var/www/html/ >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$STDCOLOR Creando base de datos $RESET"
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

	echo -e "$STDCOLOR ------------------ $RESET"
	echo -e "$STDCOLOR Instalador de GLPI $RESET"
	echo -e "$STDCOLOR ------------------ $RESET"

	echo -e "$STDCOLOR De donde lo quieres instalar $RESET"
	declare -a web
	web=("172.31.0.5" "github")

	for i in ${!web[@]}; do
    	echo -e "$i) ${web[$i]}"
	done

	read -p ">" webserver

	echo -e "$STDCOLOR Que nombre quieres para tu base de datos $RESET"
	read -p ">" database
	echo -e "$STDCOLOR Que nombre de usuario quieres para tu base de datos $RESET"
	read -p ">" username
	echo -e "$STDCOLOR Que contraseña quieres para tu base de datos $RESET"
	read -p ">" password

	apt update >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt install -y apache2 mariadb-server >>$LOGFILE 2>$ERRFILE
	test-err $?
	apt install -y php php-mysql php-intl php-zip php-xml php-curl php-gd php-mbstring unzip >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$STDCOLOR Instalando Prestashop $RESET"
	rm /var/www/html/index.html >>$LOGFILE 2>$ERRFILE
	if [ $webserver == "0" ]; then
		wget http://172.31.0.5//prestashop/prestashop_1.7.7.2.zip >>$LOGFILE 2>$ERRFILE
		test-err $?
	elif [ $webserver == "1" ]; then
		wget https://www.prestashop.com/es/system/files/ps_releases/prestashop_1.7.7.2.zip >>$LOGFILE 2>$ERRFILE
		test-err $?
	fi
	mv prestashop_1.7.7.2.zip /var/www/html >>$LOGFILE 2>$ERRFILE
	test-err $?
	cd /var/www/html >>$LOGFILE 2>$ERRFILE
	test-err $?
	unzip prestashop_1.7.7.2.zip >>$LOGFILE 2>$ERRFILE
	test-err $?

	echo -e "$STDCOLOR Dando permisos $RESET"
	chown -R www-data:www-data /var/www/html/*
	test-err $?

	echo -e "$STDCOLOR Creando base de datos $RESET"
	mysql -u root -e "create database $database;"
	test-err $?
	mysql -u root -e "create user '$username'@'localhost' identified by '$password';"
	test-err $?
	mysql -u root -e "grant all privileges on glpi.* to '$username'@'localhost';"
	test-err $?
	mysql -u root -e "flush privileges;"
	test-err $?

	echo -e "$STDCOLOR Reiniciando servidor web $RESET"
	a2enmod rewrite
	test-err $?
	systemctl restart apache2
	test-err $?
fi