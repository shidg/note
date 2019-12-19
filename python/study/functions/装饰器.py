#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import time

# 统计函数执行时间
#def show_time(func):
#    def wrapper():
#        start = time.time()
#        func(a,b)
#        end = time.time()
#        print('spend: %s'%(end - start))
#    return wrapper

#@show_time  # foo = show_time(foo)
#def foo():
#    print('I am foo……')
#    time.sleep(2)
#foo()

###############################
###############################
#def show_time(func):
#    def wrapper(a,b):
#        start = time.time()
#        func(a,b)
#        end = time.time()
#        print('spend: %s'%(end - start))
#    return wrapper

#@show_time
#def bar(a,b):
#    print(a + b)
#    time.sleep(1)
#bar(4,5)

# 带参数的装饰器函数
def logger(flag = 0):
    def show_time(func):
        def wrapper():
            start  = time.time()
            func()
            end = time.time()
            print('spend: {}' .format(end - start))
            if flag:
                print('日志已记录')
        return wrapper
    return show_time

@logger(1)
def foo():
    print('I am foo……')
    time.sleep(2)

foo()



