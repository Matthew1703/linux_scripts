SERVER="$1"
PASSWORD="$2"

OTHER_SERVER="$3"
OTHER_PASSWORD="$4"

LOCAL_IP=$(hostname -I | awk '{print $1}')

OUR_PUBKEY=$(sshpass -p "$PASSWORD" ssh root@$SERVER "sudo cat /home/DevOps/.ssh/id_rsa.pub" 1>/dev/null)

echo $OUR_PUBKEY >> "$HOME/.ssh/authorized_keys"
ssh-keyscan $SERVER >> "$HOME/.ssh/known_hosts" 2>/dev/null

if [ ! -f /home/DevOps/.ssh/id_rsa ]; then
    sudo -u DevOps ssh-keygen -t rsa -b 4096 -f /home/DevOps/.ssh/id_rsa -N "" -q
fi

cat "$HOME/.ssh/id_rsa.pub" | sshpass -p "$PASSWORD" ssh root@"$SERVER" "cat >> /home/DevOps/.ssh/authorized_keys"

sshpass -p "$OTHER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$OTHER_SERVER "
    if ! id DevOps &>/dev/null; then
        useradd DevOps -m -d /home/DevOps -s /bin/bash
        echo 'DevOps ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    fi
" 1>/dev/null


sshpass -p "$OTHER_PASSWORD" ssh root@$OTHER_SERVER "
    mkdir -p /home/DevOps/.ssh
    chmod 700 /home/DevOps/.ssh
    chown DevOps:DevOps /home/DevOps/.ssh
" 1>/dev/null


sshpass -p "$OTHER_PASSWORD" ssh root@$OTHER_SERVER "
    touch /home/DevOps/.ssh/authorized_keys
    chown DevOps:DevOps /home/DevOps/.ssh/authorized_keys
    chmod 600 /home/DevOps/.ssh/authorized_keys
" 1>/dev/null


sshpass -p "$OTHER_PASSWORD" ssh root@$OTHER_SERVER "
    echo '$OUR_PUBKEY' >> /home/DevOps/.ssh/authorized_keys
" 1>/dev/null

sshpass -p "$PASSWORD" ssh root@$SERVER "
    ssh-keyscan $OTHER_SERVER >> /home/DevOps/.ssh/known_hosts 2>/dev/null
    ssh-keyscan $LOCAL_IP >> /home/DevOps/.ssh/known_hosts 2>/dev/null
    chown DevOps:DevOps /home/DevOps/.ssh/known_hosts
    chmod 600 /home/DevOps/.ssh/known_hosts
" 1>/dev/null


sshpass -p "$PASSWORD" ssh root@$SERVER "
cat > /etc/ssh/sshd_config << 'EOF'
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
IgnoreRhosts yes
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Аутентификация
KbdInteractiveAuthentication no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthenticationMethods publickey,password

Match All
    AuthenticationMethods publickey,password
EOF

systemctl restart ssh
" 1>/dev/null