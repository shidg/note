#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# python -m pip install gevent
# 同一个线程下的任务切换 #

from greenlet import greenlet

def f1():
    print(12)
    gr2.switch() # 切换到f2去执行代码，后续代码暂停执行
    print(34)
    gr2.switch()

def f2():
    print(56)
    gr1.switch() #切换回f1执行代码，后续代码暂停执行
    print(78)
    gr1.switch()

gr1 = greenlet(f1) # 生成一个greenlet对象，但不会执行具体代码
gr2 = greenlet(f2) # 生成一个greenlet对象，但不会执行具体代码
gr1.switch()       # 对象的switch()方法，触发执行，并控制任务切换



