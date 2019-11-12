#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class PageChange():
    def __init__(self,currentpage):
        try:
            p = int(currentpage)
        except Exception as e:
            p = int(1)
        self.page = p

    @property
    def start(self):
        val = self.page
        return  val

    @property
    def end(self):
        val = self.page + 10
        return  val


li = []

for i in range(1000):
    li.append(i)

while True:
    p = input('输入要查看的页码：')
    if p == '0':
        p = 1
    obj = PageChange(p)
    print(li[obj.start:obj.end])


