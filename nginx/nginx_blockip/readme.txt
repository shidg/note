#基础的deny,allow
location / {
    allow 10.10.8.1;
    aloow 10.10.8.0/24
    deny 10.10.0.0/16
    deny all;

}


#屏蔽恶意user_agent
location / {
    if ($http_user_agent ~* "AppleWebKit/537.36 \(KHTML, like Gecko\)|Mozilla/5.0 \(Windows NT 6.1; Win64; x64; rv:56.0\)"){
        return 500;
    }
}


#url+user_agent组合
location / {
    set $flag 0;
    if ($remote_addr ~ "^(12.34|56.78)") {
        set $flag "${flag}1";
    }
    if ($http_user_agent ~* "spider") {
        set $flag "${flag}2";
    }
    if ($flag = "012") {
        return 403;
    }
}


# 通过分析访问日志屏蔽来访ip
tail -n5000 logs/access.log \
|awk '{print $1,$12}' \
|grep -i -v -E "google|baidu|qq|so|sogou" \
|awk '{print $1}'|sort|uniq -c|sort -rn \
|awk '{if($1>1000)print "deny "$2";"}' >$nginx_home/conf/sites-enabled/blocksip.conf

sbin/nginx -s reload
