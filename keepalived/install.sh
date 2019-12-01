#!/bin/bash
# File Name: -- install.sh --
# author: -- shidegang --
# Created Time: 2019-11-30 12:04:52

# 官网下载地址
# http://www.keepalived.org/download.html

# 安装依赖包
# support IPVS with IPv6.
yum install libnl-devel libnl3-dev
#
yum install -y libnfnetlink-devel openssl-devel

yum install keepalived

#tar zxvf keepalived-2.0.19.tar.gz && cd keepalived-2.0.19 &&./configure && make && make install

## iptables ##
# keepalived
-A INPUT -i eno16777985  -p vrrp -j ACCEPT
-A INPUT -d $VIP -j ACCEPT
-A OUTPUT -o  eno16777985 -p vrrp -j ACCEPT



##  chk_haproxy.sh
#!/bin/bash

A=`ps -C haproxy --no-header | wc -l`

if [ $A -eq 0 ];then
    systemctl start haproxy.service
    sleep 3
    if [ `ps -C haproxy --no-header | wc -l ` -eq 0 ];then
    ¦   systemctl stop keepalived.service
    fi
fi

chmod +x chk_haproxy.sh
