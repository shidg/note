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

obj1.per

obj1.per = 876

del obj1.per


# 使用property装饰器，保证用户仍能像访问一个属性一样简单地访问一个方法，
# 同时又能对age的取值做有效限制
class Student(object):
    @property
    def age(self): # 这里定义的是方法，但是用户调用时就像访问一个属性
        return self.__age
    @age.setter
    def age(self,value):
        if not isintance(value,int):
            raise ValueError('age must be an integer!')
        if value < 1 or value > 130:
            raise ValueError('age must between 0 ~ 100!')
        self.__age = value

a = Student()

a.age = 30 # 赋值，受到setter的约束
print(a.age)  # 取值，像访问一个变量一样简单，并不需要形如a.get_age()这样调用方法
