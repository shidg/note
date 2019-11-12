#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 如何导入一个模块
# 方式1
#from src import common

# 方式2，使用importlib模块，在用到模块的时候再动态导入
import importlib

module_name = 'src.common'
func_name = 'add'
m = importlib.import_module(module_name)
func = getattr(m,func_name)
func()

# 方式1
#func = getattr(common,func_name)
#func()
 