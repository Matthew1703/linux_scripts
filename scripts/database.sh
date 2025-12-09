#!/bin/bash

sudo dnf -y update

sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %rhel)-x86_64/pgdg-redhat-repo-latest.noarch.rpm &>/dev/null

sudo dnf -y install postgresql14-server postgresql14-contrib &>/dev/null

sudo /usr/pgsql-14/bin/postgresql-14-setup initdb 1>/dev/null

sudo systemctl enable --now postgresql-14 1>/dev/null

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" 1>/dev/null

sudo -u postgres createdb app 1>/dev/null

sudo -u postgres createdb custom 1>/dev/null

sudo -u postgres psql -c "CREATE USER app WITH PASSWORD 'app';" 1>/dev/null

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE app TO app;" 1>/dev/null

sudo -u postgres psql -c "REVOKE CONNECT ON DATABASE custom FROM app;" 1>/dev/null

sudo -u postgres psql -c "CREATE USER custom WITH PASSWORD 'custom';" 1>/dev/null

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE custom TO custom;" 1>/dev/null

sudo -u postgres psql -c "REVOKE CONNECT ON DATABASE app FROM custom;" 1>/dev/null

sudo -u postgres psql -c "CREATE USER service WITH PASSWORD 'service';" 1>/dev/null

sudo -u postgres psql -c "GRANT CONNECT ON DATABASE app TO service;" 1>/dev/null
sudo -u postgres psql -c "GRANT CONNECT ON DATABASE custom TO service;" 1>/dev/null

sudo systemctl restart postgresql-14
