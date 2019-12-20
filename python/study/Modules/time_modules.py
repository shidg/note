#!/usr/bin/env python
# -*- coding: utf-8 -*-#
'''
@Author: --- shidg ---
@Created at: 2019-12-19 14:32:15
@Version: 
@Modify by: 
'''
"""
时间元组的九个属性
    tm_year     年
    tm_mon      月(1~12)
    tm_mday     日(1~31)
    tm_hour     时(0~23)
    tm_min      分(0~59)
    tm_sec      秒(0~61, 60或61是闰秒)
    tm_wday     星期(0~6, 0是周一)
    tm_yday     第几天(1~366, 366是儒略历)
    tm_isdst    夏令时(平时用不到)
"""
# 输入某年某月末日，判断是该年的第几天ZZ

import time
str_dt = input(">>>")
tp = time.strptime(str_dt,'%Y-%m-%d')
print(tp.tm_wday)
