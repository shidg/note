#!/bin/bash
# File Name: -- mha.sh --
# author: -- shidegang --
# Created Time: 2023-01-13 20:05:35

# https://github.com/yoshinorim/


# mha node依赖的perl模块
yum install -y  perl-DBD-MySQL

tar zxvf mha4mysql-node-0.58.tar.gz && cd mha4mysql-node-0.58
yum install perl-ExtUtils-MakeMaker perl-CPAN -y
perl Makefile.PL
make && make install


# mha manager依赖的perl环境
yum install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Time-HiRes -y

tar zxvf zxvf mha4mysql-manager-0.58.tar.gz && cd zxvf mha4mysql-manager-0.58
perl Makefile.PL
make && make install

mkdir /etc/masterha
cp mha4mysql-manager-0.58/samples/conf/app1.cnf /etc/masterha

cat > /etc/masterha/app1.conf <<EOF
[server default]
#设置manager的工作目录
manager_workdir=/var/log/masterha/app1.log

#设置manager的日志
manager_log=/var/log/masterha/app1/manager.log

#设置master 保存binlog的位置，以便MHA可以找到master的日志，我这里的也就是mysql的数据目录
master_binlog_dir=/var/lib/mysql

#设置自动failover时候的切换脚本
master_ip_failover_script=/usr/local/bin/master_ip_failover

#设置手动切换时候的切换脚本
master_ip_online_change_script=/usr/local/bin/master_ip_online_change

#设置mysql中root用户的密码，这个密码是前文中创建监控用户的那个密码
password=123456

#设置监控用户root
user=root

#设置监控主库，发送ping包的时间间隔，默认是3秒，尝试三次没有回应的时候自动进行railover
ping_interval=1

#设置远端mysql在发生切换时binlog的保存位置
remote_workdir=/tmp

#设置复制用户的密码
repl_password=123456

#设置复制环境中的复制用户名
repl_user=repl

#设置发生切换后发送的报警的脚本
report_script=/usr/local/send_report

secondary_check_script= /usr/local/bin/masterha_secondary_check -s server03 -s server02

#设置故障发生后关闭故障主机脚本（该脚本的主要作用是关闭主机放在发生脑裂,这里没有使用）
shutdown_script=""

#设置ssh的登录用户名
ssh_user=root

[server1]
hostname=192.168.0.50
port=3306

[server2]
hostname=192.168.0.60
port=3306
#设置为候选master，如果设置该参数以后，发生主从切换以后将会将此从库提升为主库
#即使这个主库不是集群中事件最新的slave
candidate_master=1

#默认情况下如果一个slave落后master 100M的relay logs的话，MHA将不会选择该slave作为一个新的master，
#因为对于这个slave的恢复需要花费很长时间，通过设置check_repl_delay=0,#MHA触发切换在选择一个新的master的时候将会忽略复制延时，
#这个参数对于设置了candidate_master=1的主机非常有用，因为这个候选主在切换的过程中一定是新的master
check_repl_delay=0

[server3]
hostname=192.168.0.70
port=3306
EOF



# sshx互信
# mysql节点之间互相信任
# mhamanager到所有mysql节点的免密，如果mhamanager在其中一台slave上，意味着这台slave需要免密登录自己
