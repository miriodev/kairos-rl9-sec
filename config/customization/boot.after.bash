#!/bin/bash

## Adding mountpoint security
mount -o "remount,nosuid,rw,relatime,nodev,noexec" /home
mount -o "remount,nosuid,rw,relatime,nodev,noexec" /tmp
mount -o "remount,nosuid,rw,nodev,noexec" /var/log
mount -o "remount,nosuid,rw,nodev,noexec" /dev/shm

## Fix user password expiration and securities
chage -M 365 kairos
chage -m 1 kairos

## Apply remediation
bash /customization/xccdf_org.ssgproject.content_rule_account_password_pam_faillock_password_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_account_password_pam_faillock_system_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_password_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_system_auth.bash
bash /customization/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny.bash
bash /customization/xccdf_org.ssgproject.content_rule_no_empty_passwords.bash

## Set FirewallCMD
firewall-cmd --permanent --zone=trusted --add-interface=lo
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv4 source address="127.0.0.1" destination not address="127.0.0.1" drop'
firewall-cmd --permanent --zone=trusted --add-rich-rule='rule family=ipv6 source address="::1" destination not address="::1" drop'
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=http
