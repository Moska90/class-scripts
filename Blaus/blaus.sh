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

STDCOLOR="\e[96m"
ERRCOLOR="\e[91m"

clear


#Usuario y contraseña
echo -e "Comenzamos con tu personalizacion"
sleep 1

clear

echo -e " Que nombre de usuario quieres tener?"
read -p " >" user

echo -e " Escoge una contraseña para acceder"
read -s -p " >" password

echo -e " Cual es tu dominio?"
read -p " >" domain

clear

echo -e "$LRED Perfecto, ya estas registrado $RESET"

mkdir -p /var/www/$domain  /var/www/$domain/log

chmod 750 /var/www/$domain
chmod 750 /var/www/$domain/log

LOGFILE="/var/www/$user/log/$domain.log"
ERRFILE="/var/www/$user/log/$domain.error.log"


#Preguntas para instalacion personalizada
echo -e "$LGREEN Rellena las siguientes preguntas para terminar de configurar tu dominio,\n cuando hayas leido esto pulsa ENTER $RESET"
read

echo -e " Contry Name (2 Letters)"
read -p " >" country >>$LOGFILE 2>$ERRFILE

echo -e " Provincia?"
read -p " >" provincia >>$LOGFILE 2>$ERRFILE

echo -e " Pueblo?"
read -p " >" city >>$LOGFILE 2>$ERRFILE

echo -e " Como se llama tu empresa?"
read -p " >" empresa >>$LOGFILE 2>$ERRFILE

echo -e " Cual es tu correo electronico?"
read -p " >" correo >>$LOGFILE 2>$ERRFILE

clear

echo -e "$LYELLOW Es esta informacion correcta? $RESET"
echo -e " $country"
echo -e " $provincia"
echo -e " $city"
echo -e " $empresa"
echo -e " $domain"
echo -e " $correo"

read -e -p "$LRED Estas seguro? [y/N] $RESET" response
case $response in
    [Yy]|[Yy][Ee][Ss])
    ;;
    [Nn]|[Nn][Oo])
        echo -e "Exiting"
        exit
    ;;
esac


# Comando OpenSSL para generar un certificado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$domain.key -out /etc/ssl/certs/$domain.crt <<EOF >>$LOGFILE 2>$ERRFILE
$country
$provincia
$city
$empresa
$domain
$correo
EOF

#Creando archivo de configuracion de servidor web
echo -e "server {
        listen 443 ssl;
        listen [::]:443 ssl;
        ssl_certificate /etc/ssl/certs/$domain.crt;
        ssl_certificate_key /etc/ssl/private/$domain.key;
        include snippets/ssl-params.conf;

        root /var/www/$domain/html;

        index index.html index.htm index.nginx-debian.html;

        server_name $domain www.$domain;

        location / {
                try_files \$uri \$uri/ =404;
        }
}

server {
        listen 80;
        listen [::]:80;

        server_name $domain www.$domain;

        return 301 https://\$server_name\$request_uri;
}
" >> /etc/nginx/sites-available/$domain

