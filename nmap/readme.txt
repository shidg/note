#install
tar jxvf nmap-6.47.tar.bz2 && cd nmap-6.47
./configure
make
make install

##use

#扫描主机端口，并探测该端口软件版本，P0，扫描前不Ping主机
nmap -sV -P0 10.10.66.11

# TCP connect()扫描，这是最基本的TCP扫描方式。这种扫描很容易被检测到，在目标主机的日志中会记录大批的连接请求以及错误信息。 
nmap -sT -P0 10.10.66.11


# TCP同步扫描(TCP SYN)，因为不必全部打开一个TCP连接，所以这项技术通常称为半开扫描(half-open)。这项技术最大的好处是，很少有系统能够把这记入系统日志。不过，你需要root权限来定制SYN数据包。
nmap -sS -P0 10.10.66.11

# 秘密FIN数据包扫描、圣诞树(Xmas Tree)、空(Null)扫描模式。这些扫描方式的理论依据是：关闭的端口需要对你的探测包回应RST包，而打开的端口必需忽略有问题的包

-sF,-sX,-sN

# ping扫描，用ping方式检查网络上哪些主机正在运行。当主机阻塞ICMP echo请求包是ping扫描是无效的。nmap在任何情况下都会进行ping扫描，只有目标主机处于运行状态，才会进行后续的扫描。

nmap -sP 10.10.66.11

# -sU	如果你想知道在某台主机上提供哪些UDP(用户数据报协议,RFC768)服务，可以使用此选项。

#  -sA	ACK扫描，这项高级的扫描方法通常可以用来穿过防火墙。
#  -sW	滑动窗口扫描，非常类似于ACK的扫描。
#  -sR	RPC扫描，和其它不同的端口扫描方法结合使用。
#  -b	FTP反弹攻击(bounce attack)，连接到防火墙后面的一台FTP服务器做代理，接着进行端口扫描



-P0	在扫描之前，不ping主机。
-PT	扫描之前，使用TCP ping确定哪些主机正在运行。
-PS	对于root用户，这个选项让nmap使用SYN包而不是ACK包来对目标主机进行扫描。
-PI	设置这个选项，让nmap使用真正的ping(ICMP echo请求)来扫描目标主机是否正在运行。
-PB	这是默认的ping扫描选项。它使用ACK(-PT)和ICMP(-PI)两种扫描类型并行扫描。如果防火墙能够过滤其中一种包，使用这种方法，你就能够穿过防火墙。
-O	这个选项激活对TCP/IP指纹特征(fingerprinting)的扫描，获得远程主机的标志，也就是操作系统类型。
-I	打开nmap的反向标志扫描功能。
-f	使用碎片IP数据包发送SYN、FIN、XMAS、NULL。包增加包过滤、入侵检测系统的难度，使其无法知道你的企图。
-v	冗余模式。强烈推荐使用这个选项，它会给出扫描过程中的详细信息。
-S <IP>	在一些情况下，nmap可能无法确定你的源地址(nmap会告诉你)。在这种情况使用这个选项给出你的IP地址。
-g port	设置扫描的源端口。一些天真的防火墙和包过滤器的规则集允许源端口为DNS(53)或者FTP-DATA(20)的包通过和实现连接。显然，如果攻击者把源端口修改为20或者53，就可以摧毁防火墙的防护。
-oN	把扫描结果重定向到一个可读的文件logfilename中。
-oS	扫描结果输出到标准输出。
--host_timeout	设置扫描一台主机的时间，以毫秒为单位。默认的情况下，没有超时限制。
--max_rtt_timeout	设置对每次探测的等待时间，以毫秒为单位。如果超过这个时间限制就重传或者超时。默认值是大约9000毫秒。
--min_rtt_timeout	设置nmap对每次探测至少等待你指定的时间，以毫秒为单位。
-M count	置进行TCP connect()扫描时，最多使用多少个套接字进行并行的扫描。



目标地址可以为IP地址，CIRD地址等。如192.168.1.2，222.247.54.5/24
-iL filename	从filename文件中读取扫描的目标。
-iR	让nmap自己随机挑选主机进行扫描。
-p	端口 这个选项让你选择要进行扫描的端口号的范围。如：-p 20-30,139,60000。
-exclude	排除指定主机。
-excludefile	排除指定文件中的主机。



###nmap --script 

# dos攻击
nmap --script http-slowloris --max-parallelism 400 223.4.200.216   

## -T
nmap -T(0-5)
#置nmap的适时策略。
#Paranoid:为了避开IDS的检测使扫描速度极慢，nmap串行所有的扫描，每隔至少5分钟发送一个包； 
#Sneaky：也差不多，只是数据包的发送间隔是15秒；
#Polite：不增加太大的网络负载，避免宕掉目标主机，串行每个探测，并且使每个探测有0.4 秒种的间隔；
#Normal:nmap默认的选项，在不是网络过载或者主机/端口丢失的情况下尽可能快速地扫描；
#Aggressive:设置5分钟的超时限制，使对每台主机的扫描时间不超过5分钟，并且使对每次探测回应的等待时间不超过1.5秒钟；
#Insane:只适合快速的网络或者你不在意丢失某些信息，每台主机的超时限制是75秒，对每次探测只等待0.3秒钟。你也可是使用数字来代替这些模式，例如：-T 0等于-T Paranoid，-T 5等于-T Insane。


#枚举web站点的目录
nmap --script http-enum.nse xxx

#暴力破解密码
nmap --script=mysql-brute --script-args userdb=/var/usernames.txt,passdb=/var/password.txt 192.168.80.1
