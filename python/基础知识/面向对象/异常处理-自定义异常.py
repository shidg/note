#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class MyError(Exception):
    def __init__(self,msg):
        self.message = msg

    def __str__(self):
        return self.message

#obj = MyError('error')
#print(obj)

try:
    raise MyError('自定义错误信息')
except MyError as e:
    print(e) # print会调用对象的__str__方法

