#!/bin/bash

authselect select --force sssd
systemctl enable crond.service
systemctl enable systemd-journald.service
systemctl enable auditd.service
systemctl start systemd-journald.service
systemctl start crond.service
systemctl start auditd.service
systemctl set-default multi-user.target
systemctl mask --now rpcbind.service
systemctl mask systemd-journal-remote.socket