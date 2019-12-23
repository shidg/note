#!/usr/bin/python
# -*- coding: utf-8 -*- #
'''
author: -- shidegang --
Created Time: 2019-12-23 10:29:01
'''
#### 斐波那契数列 ######

class Fib(object):
    def __init__(self):
        self.a = 0
        self.b = 1
    def __iter__(self):
        return self
    def __next__(self):
        self.a,self.b = self.b,self.b + self.a
        if self.a > 100:
            raise StopIteration()
        return self.a

for i in Fib():
    print(i)



def fib():
    a = 0
    b = 1
    for i in range(20):
        a,b = b,a+b
        print(a)


def fib():
    a = 0
    b = 1
    while True:
        a,b = b,a+b
        yield a

f = fib()
for i in range(20):
    print(next(f))


#### findMinAndMax #####
def findMinAndMax(L):
    if len(L) == 0:
        return (None, None)

    min = L[0]
    max = L[0]

    for enum in L:
        if min > enum:
            min = enum
        if max < enum:
            max = enum

    return (min, max)


## 链式调用 ###
class url(object):
    def __init__(self,path=''):
        self._path = path

    def __getattr__(self,path):
        return url('%s/%s' %(self._path,path))
    def __str__(self):
        return self._path
    __repr__ = __str__
url().name.age.gender
