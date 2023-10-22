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

declare -A code
function country_code() {
        while IFS= read -r line; do
                # Split each line into key and value using '=' as the delimiter
                IFS='=' read -ra parts <<< "$line"
                key="${parts[0]}"
                country2="${parts[1]}"
        
                # Add the key-value pair to the associative array
                code["${country2,,}"]="$key"
        done < "2lettercode.txt"

        read -p "Enter your country: " country

        country="${country,,}"

        # Search for the 2-letter code based on the entered country
        code_found="${code[$country]}"

        # Check if the code was found
        if [ -n "$code_found" ]; then
                return 0
        else
                echo "País no encontrado en la base de datos."
        fi
}

function passwd-check() {
        if [[ "$passwd" == "$passwd2" ]]; then
                return 0
        else
                return 1
        fi
}

function dir_creation() {
        mkdir -p /var/www/$domain /var/www/$domain/html /var/www/$domain/log

        touch /var/www/$domain/log/$domain.log
        touch /var/www/$domain/log/$domain.error.log
}

clear

echo -e "$LMAGENTA Bienvenido al script de automatización de DHM$RESET"
sleep 1

echo -e " Escribe tu nombre de usuario"
read -p " >" user

#Passwd
while true; do
        echo -e " Escribe una contraseña para acceder"
        read passwd
        echo -e " Vuelve a escribir la contraseña"
        read passwd2
        passwd-check
        if [ $? -eq 0 ]; then
                break
        else
                echo "La contraseña que has escrito no es correcta, por favor escribela de nuevo."
        fi
done

echo -e " Cual es tu dominio?"
read -p " >" domain

clear

echo -e "$LRED Ya estas registrado $RESET"

LOGFILE="/var/www/$domain/log/$domain.log"
ERRFILE="/var/www/$domain/log/$domain.error.log"

dir_creation


#Preguntas para creación de la clave OpenSSL
echo -e "$LGREEN Rellena las siguientes preguntas para terminar de configurar tu dominio,\n cuando hayas leido esto pulsa ENTER $RESET"
read

country_code

echo -e " Provincia?"
read -p " >" state >>$LOGFILE 2>$ERRFILE

echo -e " Pueblo?"
read -p " >" city >>$LOGFILE 2>$ERRFILE

echo -e " Como se llama tu empresa?"
read -p " >" company >>$LOGFILE 2>$ERRFILE

echo -e " Cual es tu correo electronico?"
read -p " >" email >>$LOGFILE 2>$ERRFILE

clear

echo -e "$LYELLOW Es esta informacion correcta? $RESET"
echo -e " $country"
echo -e " $state"
echo -e " $city"
echo -e " $company"
echo -e " $domain"
echo -e " $email"

echo -e "$LRED Estas seguro? [y/N] $RESET"
read -p "  " response
case $response in
    [Yy]|[Yy][Ee][Ss])
        ;;
    [Nn]|[Nn][Oo])
        echo -e "Exiting"
        exit
        ;;
    *)
        echo -e "Exiting"
        exit
        ;;
esac


# Comando OpenSSL para generar un certificado
echo -e "$LGREEN Generando tu certificado$RESET"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$domain.key -out /etc/ssl/certs/$domain.crt <<EOF >>$LOGFILE 2>$ERRFILE
$code_found
$state
$city
$company
$company
$domain
$email
EOF


#Creando archivo de configuracion de servidor web
echo -e "$LGREEN Creando tu archivo de configuracion del servidor web$RESET"
echo -e "
server {
        listen 443 ssl;
        listen [::]:443 ssl;

        ssl_certificate /etc/ssl/certs/$domain.crt;
        ssl_certificate_key /etc/ssl/private/$domain.key;
        include snippets/ssl-params.conf;

        root /var/www/$domain/html;
        index index.html index.htm index.nginx-debian.html;
        server_name $domain     www.$domain;

        location / {
                try_files \$uri \$uri/ =404;
        }
}
server {
        listen 80;
        listen [::]:80;
        server_name $domain www.$domain;
        return 302 https://\$server_name\$request_uri;
}
" >> /etc/nginx/sites-available/$domain

cp /etc/nginx/sites-available/"$domain" /etc/nginx/sites-enabled/"$domain"

cp index.html /var/www/$domain/html/

#SFTP + User Configuration
echo -e "$LGREEN Iniciando configuracion de SFTP y Usuario$RESET"
chmod 750 /var/www/$domain
chmod -R 770 /var/www/$domain/html
chmod 750 /var/www/$domain/log

group=$company
adduser $user --force-badname --quiet <<EOF >>/dev/null 2>&1
$passwd
$passwd
EOF
addgroup $group --force-badname --quiet

usermod -a -G "$group" "$user"
chown root:$group /var/www/$domain
chown -R $user:$group /var/www/$domain/html

echo -e "
Match Group $group
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory /var/www/$domain
        PermitTunnel no
        PermitTTY no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no" >> /etc/ssh/sshd_config

systemctl restart nginx
systemctl restart sshd