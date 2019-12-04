#!/bin/bash
# File Name: -- virtual_users.sh --
# author: -- shidegang --
# Created Time: 2019-12-05 00:00:29

# how to
yum install db4

# /etc/pam.d/vsftpd,仅保留以下几行
auth	required	pam_userdb.so	db=/etc/vsftpd/virtual_users
account	required	pam_userdb.so	db=/etc/vsftpd/virtual_users
session    required     pam_loginuid.so

# cat users.txt,奇数行为用户名，偶数行为密码
admin
admincp

# 编译虚拟用户信息
db_load -T -t hash -f users.txt /etc/vsftpd/virtual_users.db

# reload 
systemctl restart vsftpd
