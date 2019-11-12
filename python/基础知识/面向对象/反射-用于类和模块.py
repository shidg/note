#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import s2
class Foo():
    stat = 'haha'

v = getattr(Foo,'stat')
print(v)

v1 = getattr(s2,'name')
v2 = getattr(s2,'func')
v3 = getattr(s2,'Foo')
#print(v1,v2(),v3().name)
print(v1,v2,v3)


