#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import subprocess

data = 'pwd'
res = subprocess.Popen(data,shell=True,stdout=subprocess.PIPE)
# subprocess会以另外一个进程运行，stdout=subprocess.PIPE参数将结果放到当前进程中，并封装进res中。
# 如果没有stdout=subprocess.PIPE的话，执行结果是取不要的。
print(str(res.stdout.read(),'utf8'))

 