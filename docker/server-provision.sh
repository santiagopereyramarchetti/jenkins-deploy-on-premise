#!/bin/bash

#############

# Mantainer:
    # Name: Santiago Pereyra Marchetti
    # Email: santiagopereyra2702@gmail.com

#############

# Description:
    # Este script va a instalar las siguientes dependencias:
        # vim, git, curl, wget, unzip 
        # nginx 
        # php 8.2 
        # php dependencies for laravel 8.2 
        # php-fpm 8.2 
        # composer 
        # supervisor 
        # mariadb
        # redis 
        # node 
        # certbot 
        # ufw
    # En un server:
        # Debian 11 - bulls eye
    # Lo deja listo para funcionar con Laravel 11 y Vue 3

#############

cat << EOF

***********************************************************************************************************
*..####...#####...##...##...........................####....####...#####...######..#####...######...####..*
*.##......##..##..###.###..........................##......##..##..##..##....##....##..##....##....##.....*
*..####...#####...##.#.##..........######...........####...##......#####.....##....#####.....##.....####..*
*.....##..##......##...##..............................##..##..##..##..##....##....##........##........##.*
*..####...##......##...##...........................####....####...##..##..######..##........##.....####..*
*.........................................................................................................*
***********************************************************************************************************

EOF

echo -e "##############"
echo "Inicializando aprovisionamiento de server...."
echo "Server: Debian 11 - bullseye"
echo -e "##############"
sleep 3
export DEBIAN_FRONTEND=noninteractive

echo -e "##############"
echo "1 - Actualizando lista de paquetes"
echo -e "##############"
sleep 3
apt update -y

echo -e "##############"
echo "2 - Instalando vim, git, curl, wget, unzip"
echo -e "##############"
apt install vim git curl wget unzip -y
sleep 3

echo -e "##############"
echo "3 - Instalando nginx"
echo -e "##############"
sleep 3
apt install nginx -y
nginx -v

echo -e "##############"
echo "4 - Instalando php 8.2"
echo -e "##############"
sleep 3
apt install apt-transport-https lsb-release ca-certificates -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update -y
apt install php8.2 -y
apt remove apache2 -y
php -v

echo -e "##############"
echo "5 - Instalando dependencias de php 8.2 para Laravel"
echo -e "##############"
sleep 3
apt install php8.2-common php8.2-cli -y
apt install php8.2-dom -y
apt install php8.2-gd -y
apt install php8.2-zip -y
apt install php8.2-curl -y
apt install php8.2-mysql -y
apt install php8.2-sqlite3 -y
apt install php8.2-mbstring -y

echo -e "##############"
echo "6 - Instalando y habilitando PHP-FPM 8.2"
echo -e "##############"
sleep 3
apt install php8.2-fpm -y
mkdir -p /run/php

echo -e "##############"
echo "7 - Instalando composer"
echo -e "##############"
sleep 3
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=$(curl -sS https://composer.github.io/installer.sig)
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') \
    { echo 'Installer verified'; } \
    else { echo 'Installer corrupt'; unlink('composer-setup.php'); } \
    echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer --version

echo -e "##############"
echo "8 - Instalando MariaDB"
echo -e "##############"
sleep 3
apt install mariadb-server mariadb-client -y
mariadb --version

echo -e "############## \n##############"
echo "9 - Instalando Redis"
echo -e "############## \n##############"
apt install redis-server -y
redis-server --version

echo -e "##############"
echo "10 - Instalando Node y Npm"
echo -e "##############"
sleep 3
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install nodejs -y
apt install build-essential -y
node -v
npm -v

echo -e "##############"
echo "11 - Instalando Certbot"
echo -e "##############"
sleep 3
apt install certbot python3-certbot-nginx -y

echo -e "##############"
echo "12 - Instalando supervisor"
echo -e "##############"
sleep 3
apt install supervisor -y
supervisord --version

echo -e "##############"
echo "Servidor aprovisionado para funcionar con Laravel 11 y Vue 3"
echo -e "##############"