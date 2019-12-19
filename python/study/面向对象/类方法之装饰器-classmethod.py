#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Foo():
    color = 'red'

    def bar(self):
        print('bar')

    #类方法函数装饰器
    @classmethod
    def bar2(cls):  # cls指代类对象本身
        print(cls.color)

    @staticmethod
    def bar3(x,y):
        print(x + y)

obj = Foo()
obj.bar()  # 普通方法，保存在类中，由对象调用,self参数自动传递

# classmethod
Foo.bar2() # 输出'red'

# staticmethod，可通过类直接调用,不需要再传递self
Foo.bar3(4,5)
