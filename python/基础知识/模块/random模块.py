#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import random
#print(random.random()) # 小于1的随机小数
#print(random.randint(1,8)) # 1--8的随机整数，包括8
#print(random.randrange(1,3)) # 1或2 ，不包含3
#print(random.choice([1,'a','b','4'])) # 随机选择数列中的元素
#print(help(random.shuffle))

#def v_code():
#    code = ''
#    for i in range(4):
#        if i == random.randint(0,3):
#            add = str(random.randrange(10))
#        else:
#            add = chr(random.randrange(65,91))
#        code += add
#    return code
#
#a = v_code()
#print(a)
#print(random.randrange(5))

while True:
    a = random.randrange(10)
    if a == 0:
        print('exit')
        break
    else:
        print('haha')
