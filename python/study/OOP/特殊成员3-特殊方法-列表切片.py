#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#__getitem__
#__setitem__
#__delitem__

class Foo():
    def __init__(self):
        pass

    def __getitem__(self, item):
        print(type(item))
        print(item.start)
        print(item.stop)
        print(item.step)

    def __setitem__(self, key, value):
        pass

    def __delitem__(self, key):
        pass

obj = Foo()

print(type(obj))
print(obj[1])