#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import s2
## 根据用户输入展示不同内容 ##
while True:
    inp = input('请输入要查看的url:\n')
#    if inp == 'f1':
#        result = s2.f1()
#        print(result)
#    elif inp == 'f2':
#        result = s2.f2()
#        print(result)
#    elif inp == 'f3':
#        result = s2.f3()
#        print(result)
#
    if hasattr(s2,inp):   # 使用反射来代替多个if判断,只需要对s2做扩展即可
        func = getattr(s2,inp)
        print('func: ',func)
        result = func()
        print(result)
    else:
        print(404)



