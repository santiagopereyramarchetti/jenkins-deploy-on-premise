#!/bin/bash

#############

# Mantainer:
    # Name: Santiago Pereyra Marchetti
    # Email: santiagopereyra2702@gmail.com

#############

# Description:
    # Va a deployar un proyecto de Laravel 11 y Vue 3 previamente subido a un repositorio de
    # GitHub. Instalara todo lo necesario para que el proyecto quede funcional

#############

# Requirements:
    # Se debe ejecutar el script server-provision.sh previamente 
    # para tener todas las dependencias instaladas
    # El proyecto debe tener la estructura de carpetas como la usada en el script
    # laravel-vue-project-inizialization.sh con una carpeta para el backend (Laravel 11)
    # y otra para el frontend (Vue 3)

    #Se debe ejecutar en la carpeta donde se deploya el proyecto

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

#### VARIABLES
PROJECT_NAME=$1
GITHUB_REPO=$2

DB_CONNECTION=$3
DB_HOST=$4
DB_PORT=$5
DB_NAME=$6
DB_USER=$7
DB_PASSWORD=$8
DB_HOST_MYSQL=${9}
CURRENT_DIR=$(pwd)

echo -e "##############"
echo "Inicializando deploy del proyecto...."
echo -e "##############"
sleep 3

echo -e "##############"
echo "1 - Clonando o pulleando el repositorio de Github"
echo -e "##############"
sleep 3
if [ -d "./backend" ] || [ -d "./frontend" ]; then
    git pull origin master
else
    git clone ${GITHUB_REPO}
    cp -r ${PROJECT_NAME}/* ${PROJECT_NAME}/.* ./
    rm -rf ${PROJECT_NAME}
    usermod -aG www-data $(whoami)
fi

echo -e "##############"
echo "1 - Instalar dependencias de Laravel"
echo -e "##############"
cd ./backend
composer install --no-interaction --optimize-autoloader --no-dev
cd ..

echo -e "##############"
echo "2 - Instalar dependencias de Vue y buildear assets"
echo -e "##############"
cd ./frontend
npm install
cd ..

echo -e "##############"
echo "3 - Inicializando MySQL si todavia no fue realizado"
echo -e "##############"
if [ -z "$(mysql -u root -e "SHOW DATABASES LIKE '$DB_NAME';")" ]; then
echo "DDBB no inicializada aun. Comenzando la inicializacion"
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST_MYSQL' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_HOST_MYSQL';
FLUSH PRIVILEGES;
EOF
else
    echo "La base de datos ya se encuentra inicializada. Saltando al siguiente paso"
fi

echo -e "##############"
echo "4 - Completando archivo .env"
echo -e "##############"
cd ./backend
cp .env.example .env
sed -i "/DB_CONNECTION=sqlite/c\DB_CONNECTION=$DB_CONNECTION" "./.env"
sed -i "/# DB_HOST=127.0.0.1/c\DB_HOST=$DB_HOST" "./.env"
sed -i "/# DB_PORT=3306/c\DB_PORT=$DB_PORT" "./.env"
sed -i "/# DB_DATABASE=laravel/c\DB_DATABASE=$DB_NAME" "./.env"
sed -i "/# DB_USERNAME=root/c\DB_USERNAME=$DB_USER" "./.env"
sed -i "/# DB_PASSWORD=/c\DB_PASSWORD=$DB_PASSWORD" "./.env"
cd ..

echo -e "##############"
echo "5 - Inicializando Laravel 11"
echo -e "##############"
cd ./backend
php artisan key:generate
php artisan storage:link
php artisan optimize:clear
php artisan down
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
chown -R www-data:www-data storage bootstrap
chmod -R 775 storage bootstrap
chmod -R 777 storage/logs storage/framework bootstrap/cache
php artisan up
cd ..

echo -e "##############"
echo "6 - Inicializando Vue 3"
echo -e "##############"
cd ./frontend
npm run build
cd ..

## Copiar configuración de nginx
echo -e "##############"
echo "7 - Modificando archivo de configuración de nginx"
echo -e "##############"
rm -f /etc/nginx/sites-available/default
tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
        server_name _;
        listen 80;
        index index.html index.php;

        location / {
                root ${CURRENT_DIR}/frontend/dist;
                try_files \$uri \$uri/ /index.html;
                gzip_static on;
        }

        location ~ \.php {
                root ${CURRENT_DIR}/backend/public;
                try_files \$uri =404;
                include /etc/nginx/fastcgi.conf;
                fastcgi_pass unix:/run/php/php8.2-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param PATH_INFO \$fastcgi_path_info;
        }

        location /api {
                root ${CURRENT_DIR}/backend/public;
                try_files \$uri \$uri/ /index.php?query_string;
        }
}
EOF
/usr/sbin/nginx -s reload

echo -e "##############"
echo "Proyecto con Laravel 11 y Vue 3 deployado con exito"
echo -e "##############"