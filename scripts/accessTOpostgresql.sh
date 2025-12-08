#!/bin/bash

#Для сервера А

#Добавление адреса в pg_hba.conf
sed -i 's,# TYPE  DATABASE        USER            ADDRESS                 METHOD,# TYPE  DATABASE        USER            ADDRESS                 METHOD\nhost\tall\t\tall\t\t<ip адрес с указанием префикса маски>\tmd5,' /etc/postgresql/14/main/pg_hba.conf

#Установка принятия всех видов соединений
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf

#Перезапуск службы
sudo systemctl restart postgresql