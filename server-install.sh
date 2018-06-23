#!/bin/bash

sudo apt update
sudo apt upgrade

sudo apt-get install apache2

echo 'ServerName 127.0.1.1

Mutex file:${APACHE_LOCK_DIR} default
DefaultRuntimeDir ${APACHE_RUN_DIR}
PidFile ${APACHE_PID_FILE}

Timeout 300
KeepAlive On

MaxKeepAliveRequests 100
KeepAliveTimeout 5

User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

HostnameLookups Off

ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn

IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf

Include ports.conf

<Directory />
        Options FollowSymLinks
        AllowOverride None
        Require all denied
</Directory>

<Directory /usr/share>
        AllowOverride None
        Require all granted
</Directory>

<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>

AccessFileName .htaccess

<FilesMatch "^\.ht">
        Require all denied
</FilesMatch>

LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent

IncludeOptional conf-enabled/*.conf

IncludeOptional sites-enabled/*.conf
' | sudo tee /etc/apache2/apache2.conf
clear

sudo apache2ctl -t
echo;

echo 'ServerTokens Prod
ServerSignature Off
TraceEnable Off
' | sudo tee /etc/apache2/conf-available/security.conf
clear

sudo a2enmod rewrite
sudo service apache2 restart
clear

sudo apt-get install mariadb-server mariadb-client
sudo systemctl stop mariadb.service
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
sudo mysql_secure_installation
sudo systemctl restart mariadb.service

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

sudo apt-get install php php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml libapache2-mod-php
sudo service apache2 restart

