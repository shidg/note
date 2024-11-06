#!/bin/bash
# File Name: -- install_filebeat.sh --
# author: -- shidegang --
# Created Time: 2024-10-16 14:28:02

# 在101 102 103三台机器上安装filebeat
end "yes\r";exp_continue
# 第一步，配置服务器免密登录
for ip in {101..103}
do
/usr/bin/expect <<-EOF
set timeout 1
spawn ssh-copy-id -p 5122 shidegang@10.203.43.$ip
expect {
"*yes/no" {send "yes\r";exp_continue} 
"*password:" {send "123456\r"}
"*]$" {send "exit\r"}
}
expec eof
EOF
done

for ip in {101..103}
    do 
    { 
        ssh -p 5122 10.203.43.$ip wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.17.7-linux-x86_64.tar.gz 2>&1 > dev/null
        if [[ $? == 0 ]];then
            echo "download success"
        else
            echo "down failed"
        fi
    } &
    done
