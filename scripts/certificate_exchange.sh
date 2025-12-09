SERVER="$1"
PASSWORD="$2"
OTHER_SERVER="$3"
OTHER_PASSWORD="$4"
LOCAL_PUBKEY="$5"

OUR_PUBKEY=$(sudo cat /home/DevOps/.ssh/id_rsa.pub &>/dev/null)

sshpass -p "$OTHER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$OTHER_SERVER "
    touch /home/DevOps/.ssh/authorized_keys
    chown DevOps:DevOps /home/DevOps/.ssh/authorized_keys
    chmod 600 /home/DevOps/.ssh/authorized_keys
" 1>/dev/null

sshpass -p "$OTHER_PASSWORD" ssh root@$OTHER_SERVER "
    echo '$OUR_PUBKEY' >> /home/DevOps/.ssh/authorized_keys
    echo '$LOCAL_PUBKEY' >> /home/DevOps/.ssh/authorized_keys
" 1>/dev/null

ssh-keyscan $OTHER_SERVER >> /home/DevOps/.ssh/known_hosts 1>/dev/null
chown DevOps:DevOps /home/DevOps/.ssh/known_hosts 
chmod 600 /home/DevOps/.ssh/known_hosts

systemctl restart ssh 