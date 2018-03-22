#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

def print_hist(h):
    for c in h:
        print(c,h[c])

h = {'a': '1', 'b': '2', 'c': '3'}
hist = {'a': 1, 'p': 1, 'r': 2, 't': 1, 'o': 1}

def invert_dict(d):
    #inverse = {}
    inverse = dict()
    for key in d:
        val = d[key]
        if val not in inverse:
            inverse[val] = [key]
        else:
            inverse[val].append(key)
    return inverse

print(invert_dict(hist))

