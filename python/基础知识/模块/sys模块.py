#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import sys   # 与python解释器交互的模块

#sys.argv  # 是一个列表，列表第一个元素是当前执行的python模块名，之后依次是传入的参数

# 场景，根据执行python模块时传递的参数不同而执行不同的功能，
# shell脚本中使用$1 ~$9来获取参数

#sys.platform # 获取python当前运行平台
#if sys.platform == 'darwin':
#    print('mac')

#sys.stdout.write('Please:')
#val = sys.stdin.readline()[:-2]
#print(val)

par_list = sys.argv
print(par_list)

if len(sys.argv) > 1:
    if sys.argv[1] == 'out':
        print('hahahahaha')
