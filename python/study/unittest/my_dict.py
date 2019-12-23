#!/usr/bin/python
# -*- coding: utf-8 -*- #
'''
author: -- shidegang --
Created Time: 2019-12-23 21:22:59
'''

class Dict(dict):
    def __init__(self,**kw):
        super().__init__(**kw)

    def __getarrt__(self,key):
        try:
            return self[key]
        except KeyError:
            raise AttributeError(r"'Dict' object has no attribute '%s'" % key)

    def __setattr__(self,key,value):
        self[key] = value
