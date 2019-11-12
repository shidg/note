#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
## 匿名函数

from functools import reduce

# 函数式编程，没必要单独定义一个函数名称的时候
print(reduce(lambda x,y : x*y, range(1,10)))
# 等效于
def add(x,y):
    return x * y
print(reduce(add, range(1,10)))