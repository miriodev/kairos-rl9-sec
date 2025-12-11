#!/bin/bash

# AuthSelect
authselect select --force sssd
authselect enable-feature with-pwhistory
authselect enable-feature with-faillock
authselect apply-changes -b

# SystemD Block
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
chage -M 365 kairos
chage -m 1 kairos
sed -i 's/%admin ALL=(ALL) NOPASSWD: ALL/%admin ALL=(ALL) ALL/g' /etc/sudoers
chmod 0750 /home/kairos

## Ssh keys fixes
ssh-keygen -A
chown root:ssh_keys "/etc/ssh/ssh_host_dsa_key" "/etc/ssh/ssh_host_ecdsa_key" "/etc/ssh/ssh_host_ed25519_key" "/etc/ssh/ssh_host_rsa_key"

## Adding mountpoint security
mount -o "remount,nosuid,rw,relatime,nodev,noexec" /home
mount -o "remount,nosuid,rw,relatime,nodev,noexec" /tmp
mount -o "remount,nosuid,rw,nodev,noexec" /var/log
mount -o "remount,nosuid,rw,nodev,noexec" /dev/shm

# Enable Selinux and Audit
grubby --update-kernel ALL --remove-args "selinux=0"
grubby --update-kernel ALL --args "audit=1"

## Apply remediation
bash /customization/xccdf_org.ssgproject.content_rule_account_password_pam_faillock_password_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_account_password_pam_faillock_system_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_password_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_system_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny.bash

## Set FirewallCMD
firewall-cmd --permanent --zone=trusted --add-interface=lo
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv4 source address="127.0.0.1" destination not address="127.0.0.1" drop'
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv6 source address="::1" destination not address="::1" drop'
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=http

## Start AIDE
/usr/sbin/aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
/usr/sbin/aide --check