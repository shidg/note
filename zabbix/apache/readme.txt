
##被监控的apache主机
#https://github.com/lorf/zapache/archive/master.zip

#http.conf
EnableSendfile on

#httpd-vhosts.conf
<VirtualHost *:80>
    ServerName localhost
<location /server-status> 
   SetHandler server-status 
   AllowOverride All
   Require all granted
</location>
</VirtualHost>

#curl http://localhost/server-status?auto


# unzip zapache-master.zip && cd zapache-master
cp zapache /etc/zabbix && chmod +x /etc/zapache
#STATUS_URL="http://localhost/server-status?auto"


# zabbix_agentd.conf
UnsafeUserParameters=1
UserParameter=zapache[*],/bin/bash /etc/zabbix/zapache \$1



#ZABBIX SERVER端
#上传模版
zapache-template-active.xml
zapache-template.xml
