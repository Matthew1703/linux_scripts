#!/bin/bash

SERVER="$1"
PASSWORD="$2"
OTHER_SERVER="$3"
OTHER_PASSWORD="$4"

echo "=== НАСТРОЙКА СЕРВЕРА: $SERVER ==="

# Обновление и установка на локальной машине
apt update -y && apt upgrade -y &>/dev/null
apt install -y openssh-server sshpass &>/dev/null

# Настройка удаленного сервера
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@"$SERVER" '
    # Обновление и установка пакетов
    apt update -y && apt upgrade -y &>/dev/null
    apt install -y openssh-server &>/dev/null
    
    # Создание пользователя DevOps
    if ! id DevOps &>/dev/null; then
        useradd DevOps -m -d /home/DevOps -s /bin/bash
        echo "DevOps ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
    
    # Настройка .ssh директории
    mkdir -p /home/DevOps/.ssh
    chmod 700 /home/DevOps/.ssh
    chown DevOps:DevOps /home/DevOps/.ssh
    
    # Генерация SSH ключа (исправленная команда)
    if [ ! -f /home/DevOps/.ssh/id_rsa ]; then
        sudo -u DevOps bash -c "ssh-keygen -t rsa -b 4096 -f /home/DevOps/.ssh/id_rsa -N \"\" -q"
    fi
    
    # Права на домашнюю директорию
    chmod 755 /home/DevOps
    
    echo "✅ Базовая настройка завершена на $HOSTNAME"
' 2>/dev/null

echo "✅ Сервер $SERVER настроен"