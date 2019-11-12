#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Bar():
    def __init__(self,sex,aihao,name='xiaoming',age='15'):
        self.name = name
        self.age = age
        self.sex = sex
        self.aihao = aihao

    def foo(self):
        print(self.name,'is',self.age,'years old.he is a ',self.sex,'he likes',self.aihao)

obj = Bar('boy','swim')
obj.foo()


## self其实就是根据类创建的那个对象

## 对象在创建的时候会自动执行__init__()方法

## __init__()称为构造方法

## 面向对象三大特性之一：封装 (__init__())