#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

## 生成器都是迭代器 ，
# 迭代器不一定是生成器


# 迭代器必定同时拥有next和iter两个方法

    # for 循环的内部工作流程
    # 调用可迭代对象的iter方法，返回一个迭代器对象
    # 不断调用可迭代对象的next方法，返回
    # 处理StopInteration

#for i in 'happy':
#    print('1')


f = open('my.txt','r')
#print(f)

#print(next(f))
#for i in f:
#    print(i)

print(max(len(x.strip())  for x in open('my.txt','r')))


