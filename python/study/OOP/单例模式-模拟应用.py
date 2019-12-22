#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


# 数据库连接
# 没必要每次请求都新建一个连接，可以使用单例模式创建一个连接池，之后的新建连接都使用已有的连接池

# 一个类嵌套的例子
class F1():
    def __init__(self):
        self.name = 123

class F2():
    def __init__(self,a):
        self.ff = a

class F3():
    def __init__(self,b):
        self.dd = b

f1 = F1()
f2 = F2(f1)
f3 = F3(f2)

print(f1.name)
print(f2.ff.name)
print(f3.dd.ff.name)
