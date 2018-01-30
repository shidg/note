#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
def recurse(n, s):
    if n == 0:
        print(s)
    else:
        recurse(n-1, n+s)

recurse(5, 1)
