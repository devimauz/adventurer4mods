#!/bin/sh
cat /etc/shadow > /mnt/shadow
/usr/sbin/sshd -f /mnt/sshd_config
