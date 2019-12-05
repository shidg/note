#!/bin/bash
# File Name: -- virtual_users.sh --
# author: -- shidegang --
# Created Time: 2019-12-05 00:00:29

# how to
yum install db4

# /etc/pam.d/vsftpd，在文件开始位置插入以下两条
# sufficient: 充分非必要条件，如果验证通过则不再进行后续验证
# 如果验证未通过也不会立即拒绝请求，而是继续使用后续其他方式验证
# 这样能保证虚拟用户和本地用户都可以登录
# 如果使用required，只能有一种用户可以登录
auth	sufficient	pam_userdb.so	db=/etc/vsftpd/virtual_users
account	sufficient	pam_userdb.so	db=/etc/vsftpd/virtual_users

# cat users.txt,奇数行为用户名，偶数行为密码
admin
admincp

# 编译虚拟用户信息
db_load -T -t hash -f users.txt /etc/vsftpd/virtual_users.db

# reload 
systemctl restart vsftpd
