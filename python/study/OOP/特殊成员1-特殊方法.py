#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

# 四个特殊成员
## __init__()  构造方法，创建对象 [  class_name() ] 的时候自动执行
## __call__()  由类创建的对象后加括号会调用该方法    obj = class_name(),  obj()
## __int__()   由类创建对象，然后对该对象执行int()的时候会调用该方法   obj = class_name() ,  int(obj)
## __str__()  由类创建对象，然后print(对象)的时候会调用该方法   obj = class_name() ,  print(obj)

class Foo():
    def __init__(self):
        print('init')

    def __call__(self, *args, **kwargs):
        print('call')

obj = Foo()  # 对象创建，自动执行__init__()

obj()        # 对象后再加括号，自动执行 __call__()
#Foo()()

class Foo1():
    def __init__(self,name,age):
        self.n = name
        self.a = age

    def __int__(self):    ## int(obj)的时候会调用该方法
        return 123

    def __str__(self):    ## print(obj)会调用该方法
        return '{}-{}'.format(self.n,self.a)

obj1 = Foo1('tom',19)
res = int(obj1)
print('res: ',res)

print('obj: ',obj1)


