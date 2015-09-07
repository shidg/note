#! /bin/bash
#安装前准备
#gcc/apache/php/gd
#yum install gcc glibc glibc-common gd gd-devel
#apache/php安装略,apache要加载mod_cgid.so，否则遇到cgi文件会直接下载从而无法出现监控界面
#selinux -->disabled

useradd -m nagios
echo "123456" | passwd --stdin nagios
groupadd nagcmd
usermod -a -G nagcmd nagios 
usermod -a -G nagcmd apache
###-a append 和-G一起用，设置用户的附属组，centos中-a不是必须的


##nagios core###
tar zxvf nagios-4.1.1.tar.gz && cd nagios-4.1.1
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf

htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

##nagios-plugin###
tar zxvf nagios-plugins-2.1.1.tar.gz && cd nagios-plugins-2.1.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios (--with-mysql=dir)
make && make install

###nrpe,用来监控远程主机###
tar zxvf nrpe-2.15.tar.gz && cd nrpe-2.15
./configure --with-nrpe-user=nagios --with-nrpe-group=nagios --with-nagios-user=nagios --with-nagios-group=nagios --enable-command-args --enable-ssl
make all
make install-plugin
make install-daemon
make install-daemon-config
##nrpe安装完成后会在/usr/local/nagios/libexec/下生成check_nrpe#
##修改objects/commands.cfg,定义check_nrpe
define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}


#检测配置文件有无语法错误
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg


###ssh非默认端口时如何监控##
##修改以下两个文件:
##localhost.cfg###
check_command                   check_ssh!5122 # !5122!是添加的内容，5122是ssh的端口

###commands.cfg##
#"check_ssh"这个"check_command"是定义在"commands.cfg"中的,定义格式如下：
define command{
        command_name    check_ssh #这里的check_ssh是自定义的命令名，完全可以是check_openssh或者其他
        command_line    $USER1$/check_ssh  -p $ARG1$ $HOSTADDRESS$ #这一行中的check_ssh指的就是/usr/local/nagios/libexec/下的check_ssh,这一行中的$ARG1$则会被替换为命令名后的第一个参数,也就是上边添加的!5122!
        }


#被监控端
##nagios-plugin##
yum -y install gcc gcc-c++ make openssl openssl-devel 
useradd -s /sbin/nologin nagios
tar zxvf nagios-plugins-2.1.1.tar.gz && cd nagios-plugins-2.1.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make && make install

##nrpe###
tar zxvf nrpe-2.15.tar.gz && cd nrpe-2.15
./configure --with-nrpe-user=nagios --with-nrpe-group=nagios --with-nagios-user=nagios --with-nagios-group=nagios --enable-command-args --enable-ssl
make all
make install-plugin
make install-daemon
make install-daemon-config

##修改/usr/local/nagios/etc/nrpe.cfg
command[check_users]=/usr/local/nagios/libexec/check_users -w 5 -c 10
command[check_load]=/usr/local/nagios/libexec/check_load -w 15,10,5 -c 30,25,20
command[check_Data]=/usr/local/nagios/libexec/check_disk -w 20% -c 10%  /Data
command[check_zombie_procs]=/usr/local/nagios/libexec/check_procs -w 5 -c 10 -s Z
command[check_total_procs]=/usr/local/nagios/libexec/check_procs -w 150 -c 200 
command[check_ssh]=/usr/local/nagios/libexec/check_ssh -p 5122 localhost
command[check_ping]=/usr/local/nagios/libexec/check_ping -H localhost -w 100.0,20% -c 500.0,60% -p 5
command[check_swap]=/usr/local/nagios/libexec/check_swap -w 20 -c 10

##启动nrpe##
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d -4

## 防火墙要开放tcp 5666端口##





###远程主机配置文件范例###
define service{
        use                             local-service         ; Name of service template to use
        host_name                       no_in_use
        service_description             SSH
        check_command                   check_nrpe!check_ssh
        notifications_enabled           0
        }

####check_nrpe!check_ssh##
##通过nrpe执行远程主机的check_ssh，并返回结果，其中check_ssh就是在远程主机的nrpe.cfg中定义的那个check_ssh##
