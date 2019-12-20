#! /usr/bin/env python
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# datetime模块下的datetime类
from datetime import datetime

# 获取当前时间
dt = datetime.now()
print(dt)

# datetime转timestamp
t = dt.timestamp()

# timestamp转datetime
dt = datetime.fromtimestamp(t) # 本地时间
udt = datetime.utcfromtimestamp(t) # 标准时间
print(t)
print(dt)
print(udt)

# str转datetime
str_date = '2019-12-19 13:34:00'
dt = datetime.strptime(str_date,'%Y-%m-%d %H:%M:%S')
print(dt)

# datetime转str
dt = datetime.now()
str_dt = dt.strftime('%Y-%m-%d %H:%M:%S')
print(str_dt,type(str_dt),end=' ')
