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

    def show(self):
        return '{} : {}'.format(self.name,self.age)
obj = Foo('tom',20)
#print(type(obj.name))

#b = 'name'
#print(obj.__dict__[b])

#print(getattr(obj,'name'))  # getattr() 字符串的形式去取对象的成员
while True:
    inp = input('>>>: \n')
    v = getattr(obj,inp)
    print(type(v))


