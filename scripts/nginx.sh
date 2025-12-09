#!/bin/bash

SERVER="$1"
PASSWORD="$2"
OTHER_SERVER="$3"
OTHER_PASSWORD="$4"

dnf -y install nginx 1>/dev/null

sed -i '/^    server {/,/^    }/d' /etc/nginx/nginx.conf

mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

if ! grep -q "sites-enabled" /etc/nginx/nginx.conf; then
    sed -i '/http {/a\    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
fi

bash -c "cat > /etc/nginx/sites-available/renue << 'EOF'
server {
    listen 80;
    server_name $SERVER;
    
    # DNS резолвер
    resolver 8.8.8.8 1.1.1.1 valid=300s;
    
    location / {
        proxy_pass https://renue.ru;
        proxy_ssl_verify off;
        
        # Заголовки
        proxy_set_header Host renue.ru;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        
        # Таймауты
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Отключаем буферизацию для отладки
        proxy_buffering off;
    }
    
    # Логи
    access_log /var/log/nginx/renue_access.log;
    error_log /var/log/nginx/renue_error.log;
}
EOF" 1>/dev/null

ln -sf /etc/nginx/sites-available/renue /etc/nginx/sites-enabled/

systemctl restart nginx