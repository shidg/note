#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Foo():
    def bar(self):
        print('bar')

    #静态函数装饰器
    @staticmethod
    def bar2():  # 静态方法，不要再加self形参
        print('123')

    @staticmethod
    def bar3(x,y):
        print(x + y)

obj = Foo()
obj.bar()  # 普通方法，保存在类中，由对象调用,self参数自动传递

# 静态方法，可通过类直接调用,不需要再传递self
Foo.bar2()
Foo.bar3(4,5)
