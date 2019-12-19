#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
## 内置函数 ##

# 这三个方法的共同点在于都是作用与  一个函数和一个列表
# 都是将列表中的元素以特定的方式传给函数去处理，并返回结果
# 其中map和filter对应的函数都是单个参数，reduce对应的函数是两个参数
# map和filter的返回结果是对象，需转为list后使用，reduce返回的结果可以直接被使用

from functools import reduce
## filter()
# 将列表中的所有元素依次传入一个带有过滤条件的函数，并将过滤结果存储为一个对象，
#s_list = ['a','b','c','d']
#
#def fun(v):
#    if v != 'b':
#        return v
#result = filter(fun,s_list)
#print(list(result))
#
## map()
# 将列表中的所有元素依次传入函数，并返回生成器，可转为list使用
#s_list2 = ['a','b','c','d']
#
#def fun2(v):
#    return v + "linux"
#
#result = map(fun2,s_list2)
#print(result) # 返回值是一个生成器
#print(list(result))  # 对象转为list后可被使用

## reduce() 需要从functions模块导入reduce

#def add(x,y):
#    return x + y

#print(reduce(add,range(1,101)))
# reduce 类似递归, 会先列表中选取1, 2传入函数，并计算出相加的结果,然后从列表中取下一个元素3,
# 和上一遍的计算结果相加，再用这个计算结果和列表中的下一个元素相相加，直到列表中的所有元素被取完。


# print(reduce(lambda x,y : x+y,range(1,6))) #匿名函数

