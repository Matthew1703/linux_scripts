#!/bin/bash

SERVER="$1"
PASSWORD="$2"
OTHER_SERVER="$3"
OTHER_PASSWORD="$4"

dnf install -y iptables-services 1>/dev/null

systemctl start iptables
systemctl enable iptables

if iptables -C INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null; then
    iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
fi

if ! iptables -C INPUT -p tcp -s $OTHER_SERVER --dport 80 -j DROP 2>/dev/null; then
    iptables -A INPUT -p tcp -s $OTHER_SERVER --dport 80 -j DROP
fi

if ! iptables -C INPUT -p tcp -s $OTHER_SERVER --dport 443 -j DROP 2>/dev/null; then
    iptables -A INPUT -p tcp -s $OTHER_SERVER --dport 443 -j DROP
fi

if ! iptables -C INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null; then
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
fi

if ! iptables -C INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null; then
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
fi

service iptables save 1>/dev/null