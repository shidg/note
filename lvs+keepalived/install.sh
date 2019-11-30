# 操作系统 CentOS-7.7
# 10.10.8.78 (DS1)
# 10.10.8.79 (DS2)
# 10.10.8.88 (VIP)
# 10.10.8.80 (RS1)
# 10.10.8.81 (RS2)
# 10.10.8.82 (RS3)

####  lvs + keepalived (DR模式) #####
# DS和RS在同一局域网,同一VLAN下
# RS的默认网关必须局域网真正的默认网关

##开启arp抑制
# DS(Director Server) RS(Real Server) 都需要
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2


# DS开启ip转发 
net.ipv4.ip_forward = 1

# DS 安装ipvsadm
yum install ipvsadm -y


# http://www.linuxvirtualserver.org/software/ipvs.html
# tar zxvf ipvsadm-1.26.tar.gz && cd ipvsadm-1.26
# make && make install

#####  DS 安装keepalived ######

yum install -y libnfnetlink-devel openssl-devel libnl-devel libnl3-devel
yum install keepalived -y

# https://www.keepalived.org/software/keepalived-2.0.19.tar.gz
#tar zxvf keepalived-2.0.19.tar.gz && cd keepalived-2.0.19
#./configure && make && make install

# /etc/keepalived/keepalived.conf

# DS上 启动keepalived
systemctl start keepalived

# RS上添加VIP
ip addr add 10.10.8.88/32 dev lo label lo:1



## PS: 本例中是把ipvs的虚拟服务器和相关的转发规则写到keepalived.conf里了(virtual_server断) 
###### 所以不必再手动设置ipvs相关####
# keepalived.conf里的virtual_server段相当于手动做如下操作：
ipvsadm -A -t 10.10.8.88:80 rr
ipvsadm -a -t 10.10.8.88:80 -r 10.10.8.80 -g
ipvsadm -a -t 10.10.8.88:80 -r 10.10.8.81 -g
ipvsadm -a -t 10.10.8.88:80 -r 10.10.8.82 -g


#  ipvsadm 相关参数
# 添加虚拟服务器
    语法:ipvsadm -A [-t|u|f]  [vip_addr:port]  [-s:指定算法]
    -A:添加
    -t:TCP协议
    -u:UDP协议
    -f:防火墙标记
    -D:删除虚拟服务器记录
    -E:修改虚拟服务器记录
    -C:清空所有记录
    -L:查看
添加后端RealServer
    语法:ipvsadm -a [-t|u|f] [vip_addr:port] [-r ip_addr] [-g|i|m] [-w 指定权重]
    -a:添加
    -t:TCP协议
    -u:UDP协议
    -f:防火墙标记
    -r:指定后端realserver的IP
    -g:DR模式
    -i:TUN模式
    -m:NAT模式
    -w:指定权重
    -d:删除realserver记录
    -e:修改realserver记录
    -l:查看
通用:
    ipvsadm -Ln:查看规则
