#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


# (列表解析)
def f(n):
    return n**2

a = [f(x) for x in range(1,10,2)]
print(a)

# 使用列表给变量赋值
list_1 = [1,2,3]

a,b,c = list_1
print(a,b,c)