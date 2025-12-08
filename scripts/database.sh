#!/bin/bash

#Обновление пакетов
sudo apt -y update
sudo apt -y upgrade

#Установка PostgeSQL
sudo apt -y install postgresql-14

#Создание БД app
sudo -u postgres createdb app

#Создание БД custom
sudo -u postgres createdb custom




#Создание пользователя app с паролем app
sudo -u postgres psql -c "CREATE USER app WITH PASSWORD 'app';"

#Предоставление всех прав пользователю app на БД app
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE app TO app;"

#Запрет доступа к БД custom пользователем app
sudo -u postgres psql -c "REVOKE CONNECT ON DATABASE custom FROM app;"




#Создание пользователя custom с паролем custom
sudo -u postgres psql -c "CREATE USER custom WITH PASSWORD 'custom'";

#Предоставление всех прав пользователю custom на БД custom
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE custom TO custom;"

#Запрет доступа к БД app пользователем custom
sudo -u postgres psql -c "REVOKE CONNECT ON DATABASE app FROM custom;"




#Создание пользователя service с паролем service
sudo -u postgres psql -c "CREATE USER service WITH PASSWORD 'service'";

#Предоставление прав на чтение БД app и custom пользователю service
sudo -u postgres psql -c "GRANT SELECT ON app TO service;"
sudo -u postgres psql -c "GRANT SELECT ON custom TO service;"


#Добавление пользователей в файл конфигурации с методом аутентицикации md5(шифрование пароля)
sudo sed -i 's/# TYPE  DATABASE        USER            ADDRESS                 METHOD/# TYPE  DATABASE        USER            ADDRESS                 METHOD\nlocal\tall\t\tapp\t\t\t\t\tmd5\nlocal\tall\t\tcustom\t\t\t\t\tmd5\nlocal\tall\t\tservice\t\t\t\t\tmd5/' /etc/postgresql/14/main/pg_hba.conf

#Перезапуск Postgres
sudo /etc/init.d/postgresql restart
