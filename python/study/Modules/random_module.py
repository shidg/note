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

# 随机数操作
    random.random()             # 0.85415370477785668   # 随机一个[0,1)之间的浮点数
    random.uniform(0, 100)      # 18.7356606526         # 随机一个[0,100]之间的浮点数
    random.randrange(0, 100, 2) # 44                    # 随机一个[0,100)之间的偶数
    random.randint(0, 100)      # 22                    # 随机一个[0,100]之间的整数
    # 随机字符操作
    seed = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+=-" # 任意字符串（作为随机字符种子库）
    random.choice(seed)             # 'd'               # 随机一个字符
    random.sample(seed, 3)          # ['a', 'd', 'b']   # 随机多个字符（字符可重复）
    ''.join(random.sample(seed,3))  # '^f^'             # 随机指定长度字符串（字符可重复）
    # 随机列表操作
    random.shuffle(list)                                # 列表中的元素打乱

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
