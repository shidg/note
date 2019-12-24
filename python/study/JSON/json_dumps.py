#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import json

# json.load()  json.dump()的操作对象是文件,json.dumps()  json.loads()的操作对象是数据

dic = {'name':'tom','age':'20','sex':'male'}

data = json.dumps(dic,sort_keys=True,ensure_ascii=False,indent=4)  # json.dumps() 将数据转换为Json格式的字符串
with open('test.json','w') as f:
    f.write(data)       # 转换格式后的数据写入文件（字典是无法直接写入文件的，write()的参数只能是字符串）


## 或者这样操作

#dic = {'name':'tom','age':'20','sex':'male'}

#with open('test.json','w') as f:
#    json.dump(dic,f)        # json.dump()的操作对象是文件，将字典直接转换为json格式并写入文件


