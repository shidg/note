# 在url中包含?的时候，nginx的$query_string变量的值就是?后边的内容，
# rewrite的正则是不匹配$query_string的，并且默认情况下，$query_string的值会自动追加到rewrite后的地址末尾。例如

rewrite ^/read.php$ /api.php
#那么，访问 read.php?tid=123 的时候实际上已经 rewrite 到了api.php?tid=123上了(自动追加$query_string)


#不想自动追加 $query_string，则在 rewrite规则的末尾添加 ?
rewrite ^/read.php$ /api.php?tid=$arg_tid&func=post?

#nginx的$args保存了$query_string中的键和值，也就是说它是一个数组,
#例如 ?tid=123，那么可以使用 $arg_tid 来匹配tid的值123



#需求：将http://jiayeah.org/890.html?tid=491&uid=79  重定向为http://jiayeah.org/index.php?m=share&id=491

if  ($query_string ~* "tid=([0-9]+)&uid=([0-9]+)"){
    set $arg1 $1;
    set $arg2 $2;
    rewrite ^(.*)/([0-9]+)\.html$   http://jiayeah.org/index.php?m=share&id=$arg1?  last;
}


#需求：将http://jiayeah.org/123.html?tid=45&pid=4 重定向为http://jiayeah.org/?p=45
RewriteEngine on
RewriteCond %{QUERY_STRING}  ^tid=([0-9]+)&pid=([0-9]+)
RewriteRule ^/([0-9]+)\.html$  http://jiayeah.org/?p=%1  [L]
