#get sourcecode
#https://github.com/antirez/hping

#install

yum -y install gcc libpcap-devel   tcl-devel

./configure
make
#make 过程中可能出现的错误：
libpcap_stuff.c:19:21: error: net/bpf.h: No such file or directory
make: *** [libpcap_stuff.o] Error 1
#解决方法
 ln -s /usr/include/pcap-bpf.h /usr/include/net/bpf.h


make strip
make install




-0 --rawip RAW IP 模式 

　　 -1 --icmp ICMP 模式 

　　 -2 --udp UDP 模式 

　　 -8 --scan 扫描模式. 

　　 例: hping --scan 1-30,70-90 -S www.target.host 

　　 -9 --listen 监听模式 
     -c 发送的报文个数
     -p 目的端口
     -s 源端口
