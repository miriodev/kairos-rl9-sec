#!/bin/bash

authselect select --force sssd
authselect enable-feature with-pwhistory
authselect enable-feature with-faillock
authselect apply-changes -b

systemctl enable crond.service
systemctl enable systemd-journald.service
systemctl enable auditd.service
systemctl start systemd-journald.service
systemctl start crond.service
systemctl start auditd.service
systemctl set-default multi-user.target
systemctl mask rpcbind.service
systemctl mask systemd-journal-remote.socket
systemctl mask nftables

sed -i 's/gpgcheck=0/gpgcheck=1/g' pgdg-redhat-all.repo
rm -f "/etc/ssh/sshd_config.d/50-redhat.conf"
sysctl -p /etc/sysctl.d/99-secfix.conf
chage -M 365 kairos
chage -m 1 kairos
ssh-keygen -A
chown root:ssh_keys /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_rsa_key