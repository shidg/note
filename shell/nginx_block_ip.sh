#! /bin/bash
nginx_home=/Data/app/nginx/
log_path=/Data/app/nginx/logs/mgpuzi/

#tail -n50000 ${log_path}access.log | grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" |awk '{print $1}'|sort|uniq -c |sort -rn -k1|awk '{if($1>150) print "deny "$2";"}'>> ${nginx_home}conf/vhosts/blockip.conf
tail -n50000 /Data/app/nginx/logs/mgpuzi/access.log | grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" |awk -F ',,' '{print $1}'|sort|uniq -c | sort -nr -k1 | awk '{if($1>150) print "deny "$2";"}' >> ${nginx_home}conf/vhosts/blockip.conf
${nginx_home}sbin/nginx -s reload
