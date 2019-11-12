#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''


class Foo():

    @property  #  属性（特性）
    def per(self):    #定义的是个方法，但是调用的时候当做字段调用
        return  1

    @per.setter
    def per(self,val):  #试图对per进行修改时此方法将执行---- >函数2
        print('per has been changed to',val)

    @per.deleter
    def per(self): #试图删除per时此方法将执行   ----------->函数3
        print('per has been deleted')

obj = Foo()
res = obj.per  #这里当做字段调用，执行函数并接收返回值
print(res)

obj.per = '123' #对per进行设置，函数2执行

del obj.per   # 对per进行删除操作，函数3执行

## 另一种等效的写法

class Foo2():
    def bar(self):
        print('123')

    def bar2(self,val):
        print('haha',val)

    def bar3(self):
        print('heihei')
    per = property(fget=bar,fset=bar2,fdel=bar3)

obj1 = Foo2()

obj.per

obj1.per = 876

del obj1.per
