#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 用于判断对象中是否有该成员
class Foo():
    def __init__(self,name,age):
        self.name = name
        self.age = age

    def show(self):
        return '{} : {}'.format(self.name,self.age)
obj = Foo('tom',20)

print(hasattr(obj,'name'))
print(hasattr(obj,'name1'))
