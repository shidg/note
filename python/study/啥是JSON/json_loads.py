#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import json

# json.load()  json.dump()的操作对象是文件,json.dumps()  json.loads()的操作对象是数据
with open('test.json','r') as f:
    data = f.read()

data = json.loads(data)  # f.read()读出的是一个str，json.loads()将其转换为字典
print(type(data))
print(data)
#with open('test.json','r') as f:
#    data = json.load(f)  # json.load()的操作对象是文件(json数据格式的文件)，读出的对象直接是一个字典
#print(type(data))
