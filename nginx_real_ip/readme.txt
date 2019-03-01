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



1. proxy_set_header    X-real-ip $remote_addr;

这句话之前已经解释过，有了这句就可以在web服务器端获得用户的真实ip

但是，实际上要获得用户的真实ip，不是只有这一个方法，下面我们继续看。

 

2.  proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;

我们先看看这里有个X-Forwarded-For变量，这是一个squid开发的，用于识别通过HTTP代理或负载平衡器原始IP一个连接到Web服务器的客户机地址的非rfc标准，如果有做X-Forwarded-For设置的话,每次经过proxy转发都会有记录,格式就是client1, proxy1, proxy2,以逗号隔开各个地址，由于他是非rfc标准，所以默认是没有的，需要强制添加，在默认情况下经过proxy转发的请求，在后端看来远程地址都是proxy端的ip 。也就是说在默认情况下我们使用request.getAttribute("X-Forwarded-For")获取不到用户的ip，如果我们想要通过这个变量获得用户的ip，我们需要自己在nginx添加如下配置：

proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;

意思是增加一个$proxy_add_x_forwarded_for到X-Forwarded-For里去，注意是增加，而不是覆盖，当然由于默认的X-Forwarded-For值是空的，所以我们总感觉X-Forwarded-For的值就等于$proxy_add_x_forwarded_for的值，实际上当你搭建两台nginx在不同的ip上，并且都使用了这段配置，那你会发现在web服务器端通过request.getAttribute("X-Forwarded-For")获得的将会是客户端ip和第一台nginx的ip。

 

那么$proxy_add_x_forwarded_for又是什么？

$proxy_add_x_forwarded_for变量包含客户端请求头中的"X-Forwarded-For"，与$remote_addr两部分，他们之间用逗号分开。

举个例子，有一个web应用，在它之前通过了两个nginx转发，即用户访问该web通过两台nginx。

在第一台nginx中,使用

proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;

现在的$proxy_add_x_forwarded_for变量的"X-Forwarded-For"部分是空的，所以只有$remote_addr，而$remote_addr的值是用户的ip，于是赋值以后，X-Forwarded-For变量的值就是用户的真实的ip地址了。

 

到了第二台nginx，使用

proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;

现在的$proxy_add_x_forwarded_for变量，X-Forwarded-For部分包含的是用户的真实ip，$remote_addr部分的值是上一台nginx的ip地址，于是通过这个赋值以后现在的X-Forwarded-For的值就变成了“用户的真实ip，第一台nginx的ip”，这样就清楚了吧。

 

最后我们看到还有一个$http_x_forwarded_for变量，这个变量就是X-Forwarded-For，由于之前我们说了，默认的这个X-Forwarded-For是为空的，所以当我们直接使用proxy_set_header            X-Forwarded-For $http_x_forwarded_for时会发现，web服务器端使用request.getAttribute("X-Forwarded-For")获得的值是null。如果想要通过request.getAttribute("X-Forwarded-For")获得用户ip，就必须先使用proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;这样就可以获得用户真实ip。
