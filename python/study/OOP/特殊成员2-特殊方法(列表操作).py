#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
## __add__ 执行 + 操作的时候调动

## __del__ 析构方法，对象被销毁时自动执行
# __init__ 构造方法，对象被创建的时候操作

## __dict__ 将对象中封装的所有内容或者类中的成员通过字典的形式返回

"""
class Foo():
    def __init__(self,name,age):
        self.name = name
        self.age = age
    def __add__(self, other): # 当对执行 + 操作的时候，将调用第一个对象的__add__方法，并把第二个对象做为参数传入
        #return 123
        #return self.age + other.age
        return Foo(self.name,other.age)

obj1 = Foo('tom',20)
obj2 = Foo('jerry',30)

print(obj1 + obj2) # 执行obj1的__add__方法，并将obg2做为参数传入
"""

"""
class Foo():
    def __init__(self,name,age):
        self.name = name
        self.age = age

obj = Foo('tom',18)

print(obj.__dict__)
print(Foo.__dict__)

"""

## 根据索引操作对象时调用的特殊方法
## __getitem__取值  __setitem__修改值  __delitem__删除值
class Foo():
    def __init__(self,name,age):
        self.name = name
        self.age = age

    def __getitem__(self, item):
        return item + 10

    def __setitem__(self, key, value):
        pass
    def __delitem__(self, key):
        pass

obj = Foo('tom',18)

print(obj[8])  # 调用 __getitem__

obj[8] = 'abc' # 调用__setitem__
print(obj[8])  # 调用 __getitem__

del obj[8]  ## 调用__delitem__
print(obj[8])  # 调用 __getitem__

##########   切片  ##########

# 对列表进行切片操作的时候，python调用的仍然是内部的getitem/setitem/delitem方法。
# 只不过传递的参数是一个slice类型的对象，slice是一个封装了起止索引、步长等值的对象
# 其逻辑如下：
class Foo3():
    def __getitem__(self, item):
        if type(item) == slice:
            print('进行切片操作')
        else:
            print('执行索引操作')
    def __setitem__(self, key, value):
        pass
        #……同理
    def __delitem__(self, key):
        pass
        # 同理
