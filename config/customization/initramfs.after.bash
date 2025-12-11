#!/bin/bash

## AuthSelect
authselect select --force sssd
authselect enable-feature with-pwhistory
authselect enable-feature with-faillock
authselect apply-changes -b

## SystemD Block
systemctl set-default multi-user.target
systemctl enable crond.service
systemctl enable systemd-journald.service
systemctl enable auditd.service
systemctl mask rpcbind.service
systemctl mask rpcbind.socket
systemctl mask systemd-journal-remote.socket
systemctl mask nftables

## GPG YUM
sed -i 's/gpgcheck=0/gpgcheck=1/g' "/etc/yum.repos.d/pgdg-redhat-all.repo"
## Remove unused files
rm -f "/etc/ssh/sshd_config.d/50-redhat.conf"

## Fix user password expiration and securities
sed -i 's/%admin ALL=(ALL) NOPASSWD: ALL/%admin ALL=(ALL) ALL/g' /etc/sudoers
chmod 0750 /home/kairos

## Ssh keys fixes
ssh-keygen -A
chown root:ssh_keys "/etc/ssh/ssh_host_dsa_key" "/etc/ssh/ssh_host_ecdsa_key" "/etc/ssh/ssh_host_ed25519_key" "/etc/ssh/ssh_host_rsa_key"

# Enable Selinux and Audit
grubby --update-kernel ALL --remove-args "selinux=0"
grubby --update-kernel ALL --args "audit=1"

## Start AIDE
/usr/sbin/aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
/usr/sbin/aide --check