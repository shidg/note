#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
# 集合的作用：
#1. 去重
#2. 关系测试

#可变集合
a = [1,'a',2]
#set01 = set(a)
#set01.add('b')
#set01.update('3ec')
#set01.update([9,'cbd'])
#set01.clear()
#print(set01)

# 不可变集合
set02 = frozenset(a)
print(set02)

# 集合操作
a = set([1,2,3,4,5])
b = set([4,5,6,7,8])
# 交集
print(a.intersection(b))
print (a & b)

# 并集
print(a.union(b))
print(a | b)

# 差集
print(a.difference(b)) # in a but not in b
print(a - b)

print(b.difference(a)) # in b but not in a
print(b - a)

# 对称差集(去掉交集之后的并集)
print(a.symmetric_difference(b))
print(a ^ b)

# 超集
print(a.issubset(b))
print(a > b)
# 子集
print(a.issubset(b))
print(a < b)
