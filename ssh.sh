#!/bin/bash

mkdir ~/.ssh
chmod 700 ~/.ssh

read -s -p "Copy your public key to the clipboard and paste it into the text box. To continue, press any key..." -n 1 response

nano ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "PubkeyAuthentication yes
PasswordAuthentication no

ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
" | sudo tee /etc/ssh/sshd_config
clear

sudo systemctl reload sshd

echo "SSH configure is success.\n"