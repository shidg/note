#!/bin/bash
# Filename:    SendEmail.sh
# Revision:    1.0
# Date:        2017/04/02
# Author:      shidg
# Description: zabbix邮件告警脚本
# Notes:       使用sendEmail
 
# 脚本的日志文件
LOGFILE="/tmp/Email.log"
:>"$LOGFILE"
exec 1>"$LOGFILE"
exec 2>&1
 
smtp_server='smtp.eg.com'    # SMTP服务器，变量值需要自行修改
username='notify@eg.com'     # 用户名，变量值需要自行修改
password='1qaz@WSX'             # 密码，变量值需要自行修改
from_email_address='notify@eg.com' # 发件人Email地址，变量值需要自行修改
to_email_address="$1"               # 收件人Email地址，zabbix传入的第一个参数
message_subject_utf8="$2"           # 邮件标题，zabbix传入的第二个参数
message_body_utf8="$3"              # 邮件内容，zabbix传入的第三个参数
 
# 转换邮件标题为GB2312，解决邮件标题含有中文，收到邮件显示乱码的问题。
message_subject_gb2312=`iconv -t GB2312 -f UTF-8 << EOF
$message_subject_utf8
EOF`
[ $? -eq 0 ] && message_subject="$message_subject_gb2312" || message_subject="$message_subject_utf8"
 
# 转换邮件内容为GB2312，解决收到邮件内容乱码
message_body_gb2312=`iconv -t GB2312 -f UTF-8 << EOF
$message_body_utf8
EOF`
[ $? -eq 0 ] && message_body="$message_body_gb2312" || message_body="$message_body_utf8"
 
# 发送邮件
sendEmail='/usr/local/bin/sendEmail'
set -x
$sendEmail -s "${smtp_server}" -xu "$username" -xp "$password" -f "$from_email_address" -t "$to_email_address" -u "$message_subject" -m "$message_body" -o message-content-type=html -o message-charset=gb2312
