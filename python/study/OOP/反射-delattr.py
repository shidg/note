#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 对象中删除一个成员,注意是在对象中添加，类并不变
class Foo():
    def __init__(self,name,age):
        self.name = name
        self.age = age

    def show(self):
        return '{} : {}'.format(self.name,self.age)
obj = Foo('tom',20)

delattr(obj,'name')
print(hasattr(obj,'name'))

