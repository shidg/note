#! /bin/bash
echo "这是一个关于shell中调用expect的测试"
ftp_user="admin"
ftp_passwd="admin"
remote_path="lamp"
remote_file_name="libevent-2.1.11-stable.tar"
#curdir=$(cd $(dirname $0);pwd)
ftp_ip="192.168.0.100"

# 开始调用expect进行自动交互
/usr/bin/expect  <<EOF

# 单独使用expect (#! /usr/bin/expect)，可以使用set var value来自定义变量,但是，
# 将expect放到shell之中时，expect中定义的变量会失效，需要在shell部分来定义变量
# expect脚本的参数以[lindex $argv n]来获取，n从0开始
set remote_path [lindex $argv 0]
set remote_file_name [lindex $argv 1]

# spawn 启动一个expect进程，后跟需要进行交互的命令
# 交互方式登录ftp
spawn lftp $ftp_user@$ftp_ip

# expect 捕获输出
# send 根据捕获的输出进行指定的输入
# expect {}，多行期望，匹配到哪条执行哪条. 切记expect与{之间有一个空格
# 背景：有时执行shell后预期结果是不固定的，有可能是询问是yes/no，有可能是要求输入密码，可以用expect{}
# exp_continue 继续执行后续动作
expect {
"Password*" {send "$ftp_passwd\r";exp_continue}
">" {send "ls\r"}
}

# 上下两个提示符相同，使用exp_continue会导致第一个动作反复执行，不会按照预期向下执行下一个动作
# 比如下边这两个动作，如果放到一个expect中，会发现get的动作反复执行，而不是像预期的那样，
# 执行完get之后执行exit
expect ">" {send "get $remote_path/$remote_file_name\r"}
expect ">" {send "exit\r"}

expect eof
EOF

exit 0
