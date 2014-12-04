#! /usr/bin/expect
set timeout 10
spawn vncpasswd
expect "Password:"
send "123456\n"
expect "Verify:"
send "123456\n"
interact
#expect eof;exit
