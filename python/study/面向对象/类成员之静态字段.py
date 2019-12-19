#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Province():
    country = '中国'  #静态字段，保存于类
    def __init__(self,name):
        self.name = name   # 普通字段，保存于对象
        #self.country = '中国'  # 如果在这里定义country的话
                               # 会导致该类实例化出来的每个对象都保存一份country变量，浪费不必要的内存

hebei = Province('河北')
henan = Province('河南')
print(hebei.country)
print(hebei.name)
