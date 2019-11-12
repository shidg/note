#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import shelve

f = shelve.open('shelve.txt')

f['info'] = {'name':'tom','age':'18'}


f2 = shelve.get('shelve.txt.db')

print(f2['info'])