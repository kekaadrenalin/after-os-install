#!/bin/bash

mkdir ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

read -r -p "Copy your public key to the clipboard and paste it into the text box. To continue, press any key..." response

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