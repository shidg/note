#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

def histogram(s):
    d = dict()
    for c in s:
        if c not in d:
            d[c] = 1
        else:
            d[c] += 1
    return d
    
print(histogram('phpchina'))
