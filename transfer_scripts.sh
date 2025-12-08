#!/bin/bash

#Переменные 
password_serverA=""
serverA=""
password_serverB=""
serverB=""
USER="root"
LOCAL_DIR="./scripts"
REMOTE_DIR="/tmp/scripts"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --password_serverA|-pswdA)
            password_serverA="$2"
            shift 2
            ;;
        --serverA|-sA)
            serverA="$2"
            shift 2
            ;;
        --password_serverB|-pswdB)
            password_serverB="$2"
            shift 2
            ;;
        --serverB|-sB)
            serverB="$2"
            shift 2
            ;;
        --help|-h)
            echo "Скрипт отправки и запуска скриптов работы с БД Postgresql"
            echo ""
            echo "Использование: $0 [ОПЦИИ]"
            echo ""
            echo "Опции:"
            echo "  --password_serverA, -p ПАРОЛЬ ОТ СЕРВЕРА А     Пароль для подключения к виртуальной машине (обязательно)"
            echo "  --serverA, -a АДРЕС СЕРВЕРА А        IP адрес виртуальной машины (обязательно)"
            echo "  --password_serverB, -p ПАРОЛЬ ОТ СЕРВЕРА B     Пароль для подключения к виртуальной машине (обязательно)"
            echo "  --serverB, -a АДРЕС СЕРВЕРА B        IP адрес виртуальной машины (обязательно)"
            echo "  --help, -h                 Эта справка"
            echo ""
            echo "Пример:"
            echo "  $0 --password_serverA qwerty12345 --serverA 127.0.0.1 --password_serverB qwerty123 --serverB 127.0.0.3"
            exit 0 
            ;;
        -*|--*)
            echo -e "\033[31mОшибка: неизвестная опция '$1'\033[0m"
            echo -e "\033[31mИспользуйте --help для справки\033[0m"
            exit 1
            ;;
        *)
            echo -e "\033[31mОшибка: лишний аргумент '$1'\033[0m"
            echo -e "\033[31mИспользуйте --help для справки\033[0m"
            exit 1
            ;;
    esac
done

required_vars=(
    "serverA:адрес для сервера A"
    "password_serverA:пароль для сервера A"
    "serverB:адрес для сервера B"
    "password_serverB:пароль для сервера B"
)

for var_pair in "${required_vars[@]}"; do
    var_name="${var_pair%%:*}"    
    var_desc="${var_pair#*:}"     
    
    if [[ -z "${!var_name}" ]]; then
        echo -e "\033[31mОшибка: не указан $var_desc\033[0m"
        echo -e "\033[31mИспользуйте --help для справки\033[0m"
        exit 1
    fi
done

if [ ! -d "$LOCAL_DIR" ]; then
    echo -e "\033[31mЛокальная директория '$LOCAL_DIR' не найдена!\033[0m"
    exit 1
fi

echo -e "\033[32mПроверяю директории на серверах...\033[0m"

for i in A B; do
    server_var="server$i"
    password_var="password_server$i"
    
    server="${!server_var}"        
    password="${!password_var}"
    
    echo -e "  $i. Проверяю директорию $REMOTE_DIR на $server..."
    
    sshpass -p "$password" ssh "$USER@$server" "
        if [ ! -d '$REMOTE_DIR' ]; then
            echo '        Создаю $REMOTE_DIR'
            mkdir -p '$REMOTE_DIR'
            chown \$(whoami) '$REMOTE_DIR'
            echo '        Готово!'
        else
            echo '        Директория уже существует'
        fi
    "
    echo -e "Сервер $i проверен\n"
done


echo "=== НАЧАЛО РАЗВЕРТЫВАНИЯ script_updatepackeges_cruser_and_addrules.sh  ==="

# 1. Сервер B
echo ""
echo "════════════════════════════════════════"
echo "СЕРВЕР B: $serverB"
echo "════════════════════════════════════════"

# Копирование на сервер B
echo "📁 Копирование скрипта на сервер B..."
sshpass -p "$password_serverB" rsync -avz \
    "$LOCAL_DIR/script_updatepackeges_cruser_and_addrules.sh" \
    "$USER@$serverB:$REMOTE_DIR/" 1>/dev/null

# Установка прав и выполнение
echo "🚀 Установка прав и выполнение на сервере B..."
sshpass -p "$password_serverB" ssh "$USER@$serverB" \
    "chmod +x '$REMOTE_DIR/script_updatepackeges_cruser_and_addrules.sh' && \
     '$REMOTE_DIR/script_updatepackeges_cruser_and_addrules.sh' '$serverB' '$password_serverB' '$serverA' '$password_serverA'"

# 2. Сервер A
echo ""
echo "════════════════════════════════════════"
echo "СЕРВЕР A: $serverA"
echo "════════════════════════════════════════"

# Копирование на сервер A
echo "📁 Копирование скрипта на сервер A..."
sshpass -p "$password_serverA" rsync -avz \
    "$LOCAL_DIR/script_updatepackeges_cruser_and_addrules.sh" \
    "$USER@$serverA:$REMOTE_DIR/" 1>/dev/null

# Установка прав и выполнение
echo "🚀 Установка прав и выполнение на сервере A..."
sshpass -p "$password_serverA" ssh "$USER@$serverA" \
    "chmod +x '$REMOTE_DIR/script_updatepackeges_cruser_and_addrules.sh' && \
     '$REMOTE_DIR/script_updatepackeges_cruser_and_addrules.sh' '$serverA' '$password_serverA' '$serverB' '$password_serverB'"

echo ""
echo "=== РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО script_updatepackeges_cruser_and_addrules.sh ==="





server_keys=("A" "B")
server_ips=("$serverA" "$serverB")
server_passwords=("$password_serverA" "$password_serverB")

# Массивы скриптов для каждого сервера
scriptsA=("certificate_exchange")
scriptsB=("certificate_exchange")

echo "=== НАЧАЛО РАЗВЕРТЫВАНИЯ ==="

# Цикл по всем серверам
for i in "${!server_keys[@]}"
do
    server_key="${server_keys[$i]}"
    server_ip="${server_ips[$i]}"
    password="${server_passwords[$i]}"
    
    echo ""
    echo "════════════════════════════════════════"
    echo "СЕРВЕР $server_key: $server_ip"
    echo "════════════════════════════════════════"
    
    # Определяем какие скрипты использовать для этого сервера
    if [ "$server_key" = "A" ]; then
        scripts=("${scriptsA[@]}")
    elif [ "$server_key" = "B" ]; then
        scripts=("${scriptsB[@]}")
    else
        echo "Неизвестный сервер: $server_key"
        continue
    fi
    
    # 1. Копирование скриптов
    echo "📁 Копирование скриптов:"
    for script in "${scripts[@]}"
    do
        echo -n "  → $script.sh... "
        
        if sshpass -p "$password" rsync -avz \
            "$LOCAL_DIR/${script}.sh" \
            "$USER@$server_ip:$REMOTE_DIR/" > /dev/null 2>&1; then
            echo "✓"
        else
            echo "✗"
        fi
    done
    
    # 2. Установка прав
    echo "🔧 Установка прав..."
    if sshpass -p "$password" ssh "$USER@$server_ip" \
        "chmod +x $REMOTE_DIR/*.sh" > /dev/null 2>&1; then
        echo "  ✓ Права установлены"
    else
        echo "  ✗ Ошибка установки прав"
    fi


    if [ "$server_key" = "A" ]; then
        SERVER_IP="$serverA"
        SERVER_PASSWORD="$password_serverA"
        OTHER_SERVER_IP="$serverB"
        OTHER_SERVER_PASSWORD="$password_serverB"
    else
        SERVER_IP="$serverB"
        SERVER_PASSWORD="$password_serverB"
        OTHER_SERVER_IP="$serverA"
        OTHER_SERVER_PASSWORD="$password_serverA"
    fi


    # 3. Выполнение скриптов
    echo "🚀 Выполнение скриптов:"
    for script in "${scripts[@]}"
    do
        echo -n "  ▶ $script... "
        
        if sshpass -p "$password" ssh "$USER@$server_ip" \
            "$REMOTE_DIR/${script}.sh '$SERVER_IP' '$SERVER_PASSWORD' '$OTHER_SERVER_IP' '$OTHER_SERVER_PASSWORD'" 1>/dev/null; then
            echo "✓"
        else
            echo "✗"
        fi

    done
done

echo ""
echo "=== РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО ==="