#!/bin/bash
# File Name: -- homework.sh --
# author: -- shidegang --
# Created Time: 2024-10-18 08:29:13
# 1. 设置一个计划任务，在每个月的最后一天，统计网站的PV和UV, 访问日志使用这个access.log即可

# 定义函数,用来计算PV/UV
getPv() {
    log_file=./access.log
    PV=$(wc -l ${log_file} | awk '{print $1}')
    UV=$(awk '{print $1}' ${log_file} | sort | uniq -c | wc -l)
    echo -e "当月的访问数据如下:\nPV: $PV\nUV: $UV"
}

#两种实现思路

### 第一种: 判断后一天是不是1号
# 计算后一天的日期,只取日期,不取年、月
next_day=$(date -d '+1 day' +%d)

# 判断后一天是不是1号
if [[ ${next_day} == 01 ]];then
    getPv
else
    :
fi


### 第二种: 判断当天是不是本月最后一天

#date +%Y-%m-01 # 取当月第一天
#$(date +%Y-%m-01) +1 month -1 day # 通过次月第一天来计算当月最后一天

# 计算当月最后一天的日期
last_day_of_this_month=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d)

# 获取当前日期
current_day=$(date +%Y-%m-%d)

# 以上两个日期进行比较
if [[ ${last_day_of_this_month} == ${current_day} ]];then
    getPv
else
    :
fi





# 注意事项：
变量名不要使用shell保留的关键词,例如
date=$()

变量名的定义要有意义

