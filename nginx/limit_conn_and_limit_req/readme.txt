# ngx_http_limit_conn_module
# 配置段：http
# 限制连接数--基于用户ip（$binary_remote_addr）或域名($server_name)

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
