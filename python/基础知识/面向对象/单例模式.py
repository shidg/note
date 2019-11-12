#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#class Foo():
#    def __init__(self,name,age):
#        self.name = name
#        self.age = age
#
#    def show(self):
#        print(self.name,self.age)

#obj = Foo('tom',20)  # obj是一个对象，也就类的一个实例。     实例化

# 单例模式---->单个实例
# 目的在于永远使用同一份实例

#v = None
#while True:
#    if v:
#        v.show()  # 永远使用同Foo的一个对象v
#    else:
#        v = Foo('tom',20)  # 对象将在这里创建
#        v.show()


class Foo():
    __v = None

    @classmethod
    def get_instance(cls):  #只有第一次会创建实例，之后永远都使用已创建的实例
        if cls:
            return cls.__v
        else:
            cls.__v = Foo()
            return cls.__v

obj1 = Foo.get_instance()  #不再使用Foo()的方式来创建对象，而是调用类中的get_instance方法
obj2 = Foo.get_instance()  #不再使用Foo()的方式来创建对象，而是调用类中的get_instance方法
obj3 = Foo.get_instance()  #不再使用Foo()的方式来创建对象，而是调用类中的get_instance方法
# obj1  obj2  obj3是完全相同的对象，实现单例效果
