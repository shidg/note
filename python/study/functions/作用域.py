#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
# L E G B

#count = 10
#
#def f():
#    global count  # global关键字，引用全局变量
#    count = 5
#    print(count)
#f()
#print(count)

x = 123
def outer():
    x = 100
    def inter():
        global x
        x = 200
    inter()
    print(x)
outer()
print(x)


#
#def outer():
#    x = 100
#    def inter():
#        nonlocal x # ----> 对父级函数中的变量进行修改，使用nonlocal
#        x = 200
#    inter()
#    return x
#result = outer()
#print(result)