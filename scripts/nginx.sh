#!/bin/bash

#Установка nginx
sudo apt -y install nginx

#Изменения в конфигурации
echo "server {
    listen 80;
    server_name localhost <ваше_доменное_имя>;

    location / {
        proxy_pass https://renue.ru;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" > /etc/nginx/sites-available/renue

#Создание ссылки
sudo ln -s /etc/nginx/sites-available/renue /etc/nginx/sites-enabled/

#Перезапуск службы
sudo systemctl restart nginx