#! /bin/bash

##hostname
sed  '/HOSTNAME/ s/^/#/;$a\HOSTNAME=oracle' /etc/sysconfig/network
IP=`ifconfig | grep inet | grep -v 127.0.0.1|grep -v inet6 |awk '{print $2}' | cut -d : -f2`
echo "$IP oracle" >> /etc/hosts
hostname oracle

###depend##
sed -i '/plugins/a\multilib_policy=all' /etc/yum.conf
yum clean all
yum install binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers kernel-headers ksh libaio libaio-devel libgcc libgomp libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel -y

##sysctl.conf
cat > /etc/sysctl.conf << EOF
#不充当路由器
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

# 处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# 开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1


# 开启并记录欺骗，源路由和重定向包
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# 禁止修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0


kernel.sysrq = 0
kernel.core_uses_pid = 1
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmall = 2097152
kernel.shmmax = 4294967296
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.core.rmem_default = 262144
net.core.rmem_max = 16777216

#网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 3000

# 系统中每一个端口最大的监听队列的长度
net.core.somaxconn = 2048

#统所能处理的不属于任何进程的TCP sockets最大数量
net.ipv4.tcp_max_orphans = 2000

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

# TIME-WAIT套接字重用功能，用于存在大量连接的服务器
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1

#系统同时保持TIME_WAIT套接字的最大数量
net.ipv4.tcp_max_tw_buckets = 5000

#减少处于FIN-WAIT-2连接状态的时间，使系统可以处理更多的连接
net.ipv4.tcp_fin_timeout = 30

#减少TCP KeepAlive连接侦测的时间，使系统可以处理更多的连接
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3

net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.ip_local_port_range = 1024 65535
vm.swappiness = 0
EOF

sysctl -p

## create group and user
groupadd oinstall
groupadd dba
useradd -m -g oinstall -G dba oracle
echo "123456"  | passwd  --stdin oracle

##修改用户限制
cat >> /etc/security/limits.conf << EOF
oracle soft nproc   2047
oracle hard nproc   16384
oracle soft nofile  1024
oracle hard nofile  65536
EOF

#用户验证选项
echo "sedsession   required      pam_limits.so" >> /etc/pam.d/login 

###oracle的安装需要图形界面，如本地安装，可直接运行在级别5，若远程安装，则服务器不必运行级别5，可以使用vnc
yum groupinstall "Desktop" -y
yum install tigervnc-server -y
echo -e 'VNCSERVERS="10:oracle"\nVNCSERVERARGS[10]="-geometry 1440x900 -nolisten tcp"' >> /etc/sysconfig/vncservers 

#设置oracle用户的vnc密码为123456
#在oracle用户家目录下创建vncpasswd.sh,并写入内容。若已存在先更名
FILE=/home/oracle/vncpasswd.sh
if [ -f $FILE ];then mv $FILE $FILE.BACK;fi
echo '#!/usr/bin/expect' >> /home/oracle/vncpasswd.sh
echo "set timeout 10" >> /home/oracle/vncpasswd.sh
echo "spawn vncpasswd" >> /home/oracle/vncpasswd.sh
echo "expect \"Password:\"" >> /home/oracle/vncpasswd.sh
echo "send \"123456\n\"" >> /home/oracle/vncpasswd.sh
echo "expect \"Verify:\"" >> /home/oracle/vncpasswd.sh
echo "send \"123456\n\"" >> /home/oracle/vncpasswd.sh
echo "interact" >> /home/oracle/vncpasswd.sh

#以oracle用户的身份，调用expect执行vncpasswd.sh脚本,设置oracle用户的vnc密码
yum install expect -y 
su - oracle -s /usr/bin/expect vncpasswd.sh

#启动vncserver
service vncserver start

iptables -I INPUT -p tcp -m tcp --dport 5910 -j ACCEPT

# create directory
mkdir -p /Data/oracle_11/app
chown -R oracle:oinstall /Data/oracle_11/app
chmod -R 755 /Data/oracle_11/app


#/home/oracle/.bash_profile
echo -e "umask 022\nexport ORACLE_BASE=/Data/oracle_11/app\nexport ORACLE_HOME=\$ORACLE_BASE/oracle/product/11.2.0.1/db_1\nexport ORACLE_SID=orc1\nexport PATH=\$PATH:\$HOME/bin:\$ORACLE_HOME/bin" >> /home/oracle/.bash_profile

sed -i '$a\if [ $USER = "oracle" ];then\
	if [ $SHELL = "/bin/ksh" ];then\
		ulimit -p 16384\
		ulimit -n 65536\
	else\
		ulimit -u 16384 -n 65536\
	fi\
fi' /home/oracle/.bash_profile
####DISPLAY###
#export DISPLAY=:0.0
#xhost +
#xdpyinfo
#su - oracle
#export DISPLAY=:0.0
#xhost +
##若有条件可直接将服务器init 5或startx##
