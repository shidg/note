#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 函数做为参数传入其他函数
# 函数能够接收其他函数做为参数
# 函数名(函数本身)就是指向函数的变量（变量可以指向函数）

abs(-10)
f = abs
#def f(n):
#    return n*n
#
def foo(a,b,func):
    return func(a) + func(b)

print(foo(-1,2,abs))
print(foo(-1,2,f))
