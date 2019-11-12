#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Foo():
    def __init__(self,name,age):
        self.name = name
        self.age = age

    def __iter__(self):
        return iter([11,22,33])  # 返回一个迭代器


## 使用for循环时，python内部执行以下步骤：

#  如果被循环对象是一个迭代器，直接执行next()方法
#  如果被循环对象是一个可迭代对象，则先执行对象的__iter__方法，获取迭代器，再next()

# 如果类中有__iter__方法，则类的对象是可迭代对象
# 1. 调用被循环对象的__iter__方法，并获取其返回值
# 2. 循环上一步中返回的对象
li = Foo('tom',18)
for i in li:  #调用li对象的__iter__方法，并获取返回值,之后对返回的对象进行循环
    print(i)

list
