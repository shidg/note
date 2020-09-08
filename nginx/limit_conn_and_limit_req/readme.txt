# ngx_http_limit_conn_module
# 配置段：http
# 限制连接数--基于用户ip（$binary_remote_addr）或域名($server_name)
# 约16000个IP地址的状态信息消耗1M内存大小
limit_conn_zone $binary_remote_addr zone=perip:10m;
limit_conn_zone $server_name zone=perserver:10m;
limit_conn_log_level info;
limit_conn_status 503;

server {
    limit_conn perip 1;
    limit_conn perserver 100;
    # 下载速度限制，针对每个连接，而非每个ip
    limit_reta 200k;

}


# ngx_http_limit_req_module
# 限制请求频率
# 配置段 http

limit_req_zone $binary_remote_addr zone=reqone:10m rate=1r/s;
limit_req_log_level info;
limit_req_status 503;
server {
    limit_req zone=reqone burst=5 nodelay;
}



# 白名单
geo $limit {
        default 1;
        10.0.0.0/8 0;
        192.168.0.0/24 0;
}

map $limit $limit_key {
        0 "";
        1 $binary_remote_addr;
}

limit_req_zone $limit_key zone=req_zone:1m rate=5r/s;

server {
        location / {
                limit_req zone=req_zone burst=10 nodelay;

                # ...
        }
}



# 多个limit_req共存，最严格的一条将生效
# 一阻止一放行则阻止，两条均阻止则更严格的一条生效
http {
      # ...

      limit_req_zone $limit_key zone=req_zone:10m rate=5r/s;
      limit_req_zone $binary_remote_addr zone=req_zone_wl:10m rate=15r/s;

      server {
            # ...
            location / {
                  limit_req zone=req_zone burst=10 nodelay;
                  limit_req zone=req_zone_wl burst=20 nodelay;
                  # ...
            }
      }
}
