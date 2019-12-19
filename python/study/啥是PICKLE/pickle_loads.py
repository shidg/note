#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''
import pickle

def foo():
    print('no ok')

with open('test.pickle','rb') as f:
    data = f.read()

data = pickle.loads(data)

print(type(data))

data()