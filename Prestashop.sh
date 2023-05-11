#!/bin/bash

apt update

apt install -y unzip

apt install -y apache2 mariadb-server

apt install -y php php-mysql php-intl php-zip php-xml php-curl php-gd php-mbstring

systemctl restart apache2

mysql -u root -e "create database prestashop;"

mysql -u root -e "create user ‘prestashop’@’localhost’ identified by ‘prestashop’;"

mysql -u root -e "grant all privileges on prestashop.* to ‘prestashop’@’localhost’;"

mysql -u root -e "flush privileges;"

rm /var/www/html/index.html

wget http://172.31.0.5//prestashop/prestashop_1.7.7.2.zip

mv prestashop_1.7.7.2.zip /var/www/html

cd /var/www/html

unzip prestashop_1.7.7.2.zip

unzip -o prestashop.zip

chown -R www-data:www-data /var/www/html/*

a2enmod rewrite

systemctl restart apache2
