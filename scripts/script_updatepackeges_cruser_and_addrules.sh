#!/bin/bash

SERVER="$1"
PASSWORD="$2"
OTHER_SERVER="$3"
OTHER_PASSWORD="$4"

echo "=== НАСТРОЙКА СЕРВЕРА: $SERVER ==="

dnf update -y 1>/dev/null

dnf install -y openssh-server openssh-clients 1>/dev/null

# Создание пользователя DevOps

if [ ! -d "/home/DevOps" ]; then
    useradd DevOps -m -d /home/DevOps -s /bin/bash
    echo "DevOps ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    mkdir -p /home/DevOps/.ssh
    chmod 700 /home/DevOps/.ssh
    chown DevOps:DevOps /home/DevOps/.ssh
fi

if [ ! -f /home/DevOps/.ssh/id_rsa ]; then
    echo "Генерация SSH ключа..."
    sudo -u DevOps ssh-keygen -t rsa -b 4096 -f /home/DevOps/.ssh/id_rsa -N "" -q 1>/dev/null
fi

chmod 755 /home/DevOps

systemctl enable sshd
systemctl start sshd

echo "✅ Базовая настройка завершена на $HOSTNAME"
echo "✅ Сервер $SERVER настроен"