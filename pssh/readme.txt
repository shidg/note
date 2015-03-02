# get
wget https://parallel-ssh.googlecode.com/files/pssh-2.3.1.tar.gz

# install
tar zxvf pssh-2.3.1.tar.gz
cd pssh-2.3.1
python setup.py install


#pssh相关参数

pssh在多个主机上并行地运行命令
-h 执行命令的远程主机列表,文件内容格式[user@]host[:port]
如 test@172.16.10.10:229
-H 执行命令主机，主机格式 user@ip:port
-l 远程机器的用户名
-p 一次最大允许多少连接
-P 执行时输出执行信息
-o 输出内容重定向到一个文件
-e 执行错误重定向到一个文件
-t 设置命令执行超时时间
-A 提示输入密码并且把密码传递给ssh(如果私钥也有密码也用这个参数)
-O 设置ssh一些选项
-x 设置ssh额外的一些参数，可以多个，不同参数间空格分开
-X 同-x,但是只能设置一个参数
-i 显示标准输出和标准错误在每台host执行完毕后

#附加工具

pscp 传输文件到多个hosts，类似scp
pscp -h hosts.txt -l irb2 foo.txt /home/irb2/foo.txt
pslurp 从多台远程机器拷贝文件到本地
pnuke 并行在远程主机杀进程
pnuke -h hosts.txt -l irb2 java
prsync 使用rsync协议从本地计算机同步到远程主机
prsync -r -h hosts.txt -l irb2 foo /home/irb2/foo
