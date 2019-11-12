#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

try:
    raise Exception('不想玩了') # 主动触发异常
except Exception as e:
    print(e)

## 应用场景

def db():
    pass

def web():
    try:
        result = db()
        if not result:
            raise Exception('数据库连接失败') ## 在需要的时候定制错误信息
    except Exception as e: # 如果db()抛了异常，这里会捕获并处理
                           # 如果db()没哟抛异常，这里则负责捕获其他错误
        str_err = str(e)
        # 错误信息写入日志
