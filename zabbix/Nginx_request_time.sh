#!/bin/bash
# DateTime: 2018-11-15
# AUTHOR：shidg
# Description：zabbix监控nginx 响应时间 (request_time upstream_response_time)
# Note：此脚本需要配置在被监控端
 
NGINX_HOME=/Data/app/nginx
LOG_NAME=access_log_$2.eg.com.https
TMP_FILE=/tmp/access_log
 
# 定义函数

function request {

	awk 'BEGIN {sum=0} {sum+=$(NF-1)} END {print sum/NR}' $TMP_FILE
}

function response {
	awk 'BEGIN {sum=0} {sum+=$NF} END {print sum/NR}' $TMP_FILE
}

# 统计最近1分钟的平均响应时间

# 截取最近1分钟的日志,写入临时文件
[ ! $PWD == ${NGINX_HOME}/logs ] && cd ${NGINX_HOME}/logs

tac ${LOG_NAME} | awk 'BEGIN{ "date -d \"-1 minute\" +\"%H:%M:%S\"" | getline min1ago } { if (substr($4, 14) > min1ago) print $0;else exit }' > $TMP_FILE

# 执行函数，计算响应时间

$1
