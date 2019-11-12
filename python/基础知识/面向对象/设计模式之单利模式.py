#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 公有成员 私有成员

class Foo():
    def __init__(self,name,age):
        self.name = name  # 公有成员，可以被对象调用
        self.__age = age  # 私有成员，不能被对象调用,可以被类内部的方法调用

    def show(self):
        return self.__age # 类内部的方法调用__age

obj = Foo('tom',18)

print(obj.name)
print(obj.show())
