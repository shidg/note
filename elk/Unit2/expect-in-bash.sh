#!/bin/bash
# File Name: -- expect.sh --
# author: -- shidegang --
# Created Time: 2024-10-15 18:17:35
IpGroup=('10.203.43.101' '10.203.43.102')
 
for ip in ${IpGroup[@]}
do
   /usr/bin/expect <<-EOF
   set timeout 3                      
   spawn ssh -p 5122 shidegang@$ip
   expect {
    "*yes/no" { send "yes\r"; exp_continue }
    "*password:" { send "123456\r" }
    }
   expect "*$"
   send "df -h\r" 
   expect "*$"
   send "exit\r"
   interact       
   expect eof
EOF
done
