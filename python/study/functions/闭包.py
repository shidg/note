#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 闭包
#1 在一个外函数中定义了一个内函数。
#2 内函数里运用了外函数的临时变量。
#3 并且外函数的返回值是内函数的引用 (内函数的引用---->内函数的函数名)

def outer():
    x = 10
    def inner():
        print(x)

    return inner

# 如何调用inner函数？
outer()()
f = outer()
f()

# inner() 无法直接调用,inner是outer内部的一个局部变量，无法在函数外调用

