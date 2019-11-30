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
tar zxvf keepalived-2.0.19.tar.gz && cd keepalived-2.0.19 &&./configure && make
&& make install

## iptables ##
