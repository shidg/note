#当用户请求经过多层代理才能到达服务器时，nginx如何获取用户的真实IP

location / {
    root /var/www/www.hi-linux.com;
    set_real_ip_from  192.168.2.0/24;
    set_real_ip_from  128.22.189.11;
    real_ip_header    X-Forwarded-For;
    real_ip_recursive on; #递归排除
}

#set_real_ip_from 192.168.1.0/24; #真实服务器上一级代理的IP地址或者IP段,可以写多行。
#set_real_ip_from 192.168.2.1;
#real_ip_header X-Forwarded-For;  #从哪个header头检索出要的IP地址。
#real_ip_recursive on; #递归的去除所配置中的可信IP。

#每一条set_real_ip_from就代表一层代理
#递归的去除所配置中的可信IP，排除set_real_ip_from里面出现的IP。如果出现了未包含在这些IP段的IP，那么这个IP将被认为是用户的IP
#在real_ip_recursive off或者不设置的情况下,仅192.168.2.0、24(第一条set_real_ip_from)被排除掉，其它的IP地址都被认为是用户的ip地址。
