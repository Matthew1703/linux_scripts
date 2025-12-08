#!/bin/bash


#Запрет доступа с другого сервера
sudo iptables -A INPUT -p tcp -s IP_адрес_сервера_postgres --dport 80 -j DROP
sudo iptables -A INPUT -p tcp -s IP_адрес_сервера_postgres --dport 443 -j DROP

#Сохранение правил
sudo mkdir /etc/iptables
sudo iptables-save > /etc/iptables/rules.v4