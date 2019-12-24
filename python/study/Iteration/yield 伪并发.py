#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import time
import random

def consumer(name):
    print('%s 准备抢包子了！'%(name))
    while True:
        baozi = yield
        print('包子 %s上桌了，被%s吃掉了'%(baozi,name))

def producer(name1,name2):
    c1 = consumer(name1) # 返回生成器对象，赋值给c1，并不会运行函数中的任何代码
    c2 = consumer(name2) # 返回生成器对象，赋值给c2，并不会运行函数中的任何代码
    next(c1)   # 执行函数中的第一步操作，打印 Tony，准备抢包子了,之后遇到了yield，在将要为变量'baozi'赋值的时候停止。
    next(c2)   # 执行函数中的第一步操作，打印 Jerry，准备抢包子了，同上
    print('开始做包子了')
    for i in range(5):
        time.sleep(1)
        print('包子做好了')
        d = random.randint(1,9)
        if d % 2 == 0:
            c1.send(i)  # 对生成器对象执行send方法，会使函数继续执行，完成对变量'baozi'进行赋值，并且执行后边的print
        else:
            c2.send(i)

producer('Tony','jerry')