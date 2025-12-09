#!/bin/bash

SERVER="$1"
PASSWORD="$2"
OTHER_SERVER="$3"
OTHER_PASSWORD="$4"

#Добавление адреса в pg_hba.conf
sed -i "s,# TYPE  DATABASE        USER            ADDRESS                 METHOD,# TYPE  DATABASE        USER            ADDRESS                 METHOD\nhost\tall\t\tall\t\t$OTHER_SERVER/32\tmd5," /var/lib/pgsql/14/data/pg_hba.conf

#Установка принятия всех видов соединений
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/14/data/postgresql.conf


firewall-cmd --permanent --add-port=5432/tcp 1>/dev/null

firewall-cmd --reload 1>/dev/null

#Перезапуск службы
systemctl restart postgresql-14