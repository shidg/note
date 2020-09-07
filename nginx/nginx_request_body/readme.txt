# nginx在处理请求前默认不会读取$request_body的内容，所以nginx日志中默认不会保存POST数据

# 当nginx用作反向代理(即配置了proxy_pass或fastcgi_pass的location)时,直接在log_format中添加$request_body就可以记录POST数据了

# nginx没有配置为proxy_pass或者fastcgi_pass模式的时候，如果想记录POST数据，需要借助LUA模块，在输出log前读一遍request_body
location  /test {
    lua_need_request_body on;
    content_by_lua 'local s = ngx.var.request_body';
    ...
}
