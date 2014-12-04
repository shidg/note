-m multiport --source-ports         多个源端口
             --destination-ports    多个目的端口
             --ports                源和目的端口

-m limit     --limit    速率(3/minute 每分钟三个数据包)
             --limit-burst  峰值速率(100 表示最大不能超过100个数据包)

#防止ping攻击
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/m -j ACCEPT 

-m connlimit --connlimit-above n 单个ip最大允许n个连接，例如：
#单个ip最大syn连接数
iptables –A INPUT –i eth0 –p tcp --syn -m connlimit --connlimit-above 15 -j DROP

#单个ip最多3个连接
iptables -I INPUT -p tcp -dport 22 -m connlimit --connlimit-above 3 -j DROP

#防止单个ip访问量过大
iptables -I INPUT -p tcp --dport 80 -m connlimit --connlimit-above 30 -j DROP

-m recent   --set
            --name
            --update
            --seconds
            --hitcount
#例子，如果一分钟之内，同一ip的ssh请求达到5次，则拒绝连接
-A INPUT -m tcp -p tcp --dport 5122 -m state --state NEW -m recent --set --name SSH
-A INPUT -m recent --update --name SSH --seconds 60 --hitcount 5 -j LOG --log-prefix "ssh attack"
-A INPUT -m recent --update --name SSH --seconds 60 --hitcount 5 -j DROP




#1.防止syn攻击
#思路一：限制syn的请求速度（这个方式需要调节一个合理的速度值，不然会影响正常用户的请求）
iptables -N syn-flood 
iptables -A INPUT -p tcp --syn -j syn-flood 
iptables -A syn-flood -m limit --limit 1/s --limit-burst 4 -j RETURN 
iptables -A syn-flood -j DROP 


#思路二：限制单个ip的最大syn连接数
iptables –A INPUT –i eth0 –p tcp --syn -m connlimit --connlimit-above 15 -j DROP 


#2. 防止DOS攻击
#单个IP最多连接3个ssh会话,要注意还要有一条ACCEPT的规则ssh连接才能建立，并且要注意规则的顺序,如果ACCEPT在前则connlimit不会生效
iptables -I INPUT -p tcp -dport 22 -m connlimit --connlimit-above 3 -j DROP 
iptables -I INPUT -p tcp -dport 22 -state --state NEW -j ACCEPT 

#利用recent模块抵御DOS攻击
iptables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH  
#只要是新的连接请求，就把它加入到SSH列表中
iptables -I INPUT -p tcp --dport 22 -m state NEW -m recent --update --seconds 300 --hitcount 3 --name SSH -j DROP  
#5分钟内你的尝试次数达到3次，就拒绝提供SSH列表中的这个IP服务。被限制5分钟后即可恢复访问。


#3. 防止单个ip访问量过大
iptables -I INPUT -p tcp --dport 80 -m connlimit --connlimit-above 30 -j DROP 

#4. 木马反弹
iptables –A OUTPUT –m state --state NEW –j DROP 

#5. 防止ping攻击
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/m -j ACCEPT 
