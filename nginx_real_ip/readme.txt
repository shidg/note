#当用户请求经过多层代理才能到达服务器时，nginx如何获取用户的真实IP


# 方式一  realip 模块 --with-http_realip_module

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


如何正确传递客户真实ip很重要，
尤其是第一层代理，一定要正确地将用户真实ip传递到下一层代理或者业务服务器
作为第一层代理，要将用户的握手ip赋值给X-real-ip向后传递，如下：
proxy_set_header    X-real-ip $remote_addr;



方式二  XXF (X_Forwarded_For)

XXF是一个http扩展头，最开始是由 Squid 引入，用来表示 HTTP 请求端真实 IP。如今它已经成为事实上的标准，被各大 HTTP 代理、负载均衡等转发服务广泛使用，并被写入 RFC 7239（Forwarded HTTP Extension）标准之中。

nginx的两个变量：
$http_x_forwarded_for：就是该服务器上的X-Forwarded-For的值。如果这是第一层代理，该值为空，否则该值为上层代理传递过来的XXF值。
$proxy_add_x_forwarded_for：存储了上层传递过来的XXF和上层代理本身的ip,是一个累加值 [client,proxy1, proxy2,...]

proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;


那么$proxy_add_x_forwarded_for又是什么？

$proxy_add_x_forwarded_for变量包含客户端请求头中的"X-Forwarded-For"，与$remote_addr两部分，他们之间用逗号分开。

举个例子，有一个web应用，在它之前通过了两个nginx转发，即用户访问该web通过两台nginx。

在第一台nginx中,使用

proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;

现在的$proxy_add_x_forwarded_for变量的"X-Forwarded-For"部分是空的，所以只有$remote_addr，而$remote_addr的值是用户的ip，于是赋值以后，X-Forwarded-For变量的值就是用户的真实的ip地址了。

到了第二台nginx，使用
proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;

现在的$proxy_add_x_forwarded_for变量，X-Forwarded-For部分包含的是用户的真实ip，$remote_addr部分的值是上一台nginx的ip地址，于是通过这个赋值以后现在的X-Forwarded-For的值就变成了"用户的真实ip，第一台nginx的ip"
