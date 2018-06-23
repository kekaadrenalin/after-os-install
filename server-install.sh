#!/bin/bash

sudo apt update
sudo apt upgrade

sudo apt-get install apache2

sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
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

sudo cp /etc/apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf.bak
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

sudo apt-get install phpmyadmin php-mbstring php-gettext
sudo phpenmod mbstring
sudo service apache2 restart

sudo cp /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
echo 'Listen 127.0.1.1:8080

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
' | sudo tee /etc/apache2/ports.conf
clear

sudo apt-get install nginx
sudo service nginx restart

sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
echo 'user www-data;
worker_processes 4;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}

http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;


        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;

        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
' | sudo tee /etc/nginx/nginx.conf
clear

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
echo 'server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /var/www/html;
        index index.html index.php index.htm;

        server_name localhost;

        location ~* ^(?!/phpmyadmin/).+\.(jpg|jpeg|gif|png|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|tar|wav|bmp|rtf|swf|ico|flv|txt|xml|docx|xlsx)$ {
                access_log off;
                expires 30d;
        }


        location ~ /\.ht {
                deny all;
        }


        location / {
                proxy_pass http://127.0.1.1:8080/;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-for $remote_addr;
                proxy_set_header Host $host;
                proxy_connect_timeout 300;
                proxy_send_timeout 300;
                proxy_read_timeout 300;
                proxy_redirect off;
                proxy_set_header Connection close;
                proxy_pass_header Content-Type;
                proxy_pass_header Content-Disposition;
                proxy_pass_header Content-Length;
        }
}
' | sudo tee /etc/nginx/sites-available/default
clear

sudo service nginx restart
sudo apt-get install libapache2-mod-rpaf