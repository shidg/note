#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
# 公有成员 私有成员 (成员前增加__)

class Foo():
    def __init__(self,name,age):
        self.name = name  # 公有成员，可以被对象调用
        self.__age = age  # 私有成员，不能被对象调用,可以被本类内部的方法调用，
                          # 子类不能访问父类的私有成员

    def show(self):
        return self.__age # 类内部的方法调用__age

obj = Foo('tom',18)

print(obj.name)
print(obj.show())

class Foo1():
    v = '123'   # 静态字段
    __t = '456' # 静态字段变为私有成员
    def __init__(self):
        pass

    def show(self):
        return Foo1.__t

    @staticmethod  # 静态方法
    def stat():
        return Foo1.__t

print(Foo1.v)  #静态字段直接用类来调用，无需实例化对象

print(Foo1().show())
print(Foo1.stat())  # 静态方法的调用


## 私有方法

class Foo2():
    def __init__(self):
        pass

    def __f1(self):
        return 123

    def f2(self):
        return  self.__f1()


obj = Foo2()

print(obj.f2())
