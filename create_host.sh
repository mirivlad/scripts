#!/bin/bash
#Проверка запуска скрипта из под root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

CUR_USER="$(printenv SUDO_USER)"
if [[ -z "$USER" ]]; then
    CUR_USER="www-data"
fi

echo "Script run under user: $CUR_USER"
read -n 1 -s -r -p "Press any key to continue... " key

# Проверяем, установлены ли необходимые пакеты
if ! command -v nginx > /dev/null; then
    echo "Установка nginx..."
    sudo apt-get install nginx -y
fi

if ! command -v php > /dev/null; then
    echo "Установка php-fpm..."
    sudo apt-get install php php-bcmath php-bz2 php-common php-curl php-fpm php-gd php-imagick php-intl php-mbstring php-mcrypt php-mysql php-opcache php-xml php-xmlrpc php-xsl php-yaml php-zip -y
fi

if ! command -v mysql > /dev/null; then
    echo "Установка mysql..."
    sudo apt-get install mariadb-server -y
fi

PHP_VER="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")"
echo "Installed PHP version: $PHP_VER"

# Запрашиваем у пользователя необходимые данные
read -p "Введите имя домена: " domain
read -p "Введите имя базы данных: " db_name
read -p "Введите имя пользователя базы данных: " db_user
read -p "Введите пароль пользователя базы данных: " db_pass

echo "Создаем директорию для сайта и даем на нее права пользователю"
mkdir -p /var/www/$domain
chmod -R 775 /var/www/$domain
chown -R $CUR_USER:www-data /var/www/$domain
echo "Генерируем конфигурационный файл php-fpm"
echo "[$domain]
user = $CUR_USER
group = $CUR_USER
listen = /run/php/php$PHP_VER-fpm_$domain.sock
listen.owner = www-data
listen.group = www-data
listen.mode=0660
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

" > /etc/php/$PHP_VER/fpm/pool.d/$domain.conf 
echo "Генерируем конфигурационный файл виртуального хоста nginx"
echo "server {
    listen 80;
    server_name $domain;
    root /var/www/$domain;
    index index.php index.html index.htm;
    
    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php$PHP_VER-fpm_$domain.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}" > /etc/nginx/sites-available/$domain

echo "Создаем базу данных, пользователя и даем на нее права"
echo "CREATE DATABASE $db_name;" | mysql -u root
echo "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" | mysql -u root
echo "GRANT ALL ON $db_name.*  TO '$db_user'@'localhost';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root

echo "Включаем конфигурацию виртуального хоста nginx"
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

echo "Добавляем запись в /etc/hosts"
echo "127.0.0.1 $domain" >> /etc/hosts

echo "Перезапускаем сервисы"
service nginx restart
service php$PHP_VER-fpm restart

# Выводим сообщение об успешном завершении
echo "Установка и настройка завершены!"
