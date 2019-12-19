#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 关键字参数
def user_info(name,age):
    print('hello, %s! You are %d years old'%(name,age))

user_info(name='Tom',age=30)

# 默认值参数
def user_info_1(name,age=30):
    print('hello, %s! You are %d years old'%(name,age))
user_info_1('Tom')

# 可变长参数(元组)
def add(*args):
    if isinstance(args,tuple):
        print('haha')
    my_sum = 0
    for i in args:
        my_sum += i
    print(my_sum)
add(1,2,3,4,7,9)

# 可变长参数(字典)
def user_info_2(name,age,**kwargs):
    print('hello,%s,You info is:\nAge:%d'%(name,age))
    for k,v in kwargs.items():
        print(k,':',v)

user_info_2('tom',22,job='IT',sex='male')
