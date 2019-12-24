#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

import pickle

def foo():
    print('ok')

data = pickle.dumps(foo)

with open('test.pickle','wb') as f:
    f.write(data)
