#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#### python中，一切事物都是对象  ########

#class Foo():
#    print('123')

#obj = Foo()

# obj是Foo类的对象，而Foo类是type的对象。
# 类都是type类的对象，平时所说的对象时指的普通类的对象
# 可以用以下方式声明同一个类：

#def function():
#    print('123')

#Foo = type('Foo',(object),{'func': function})
#obj = Foo()

## 所以在创建一个类的时候，python会自动执行type类的__init__方法，因为类是type类实例化出的对象
## 跟平时使用类实例化一个对象的时候，会自动执行类中的__init__方法是一样的。

## 如果需要对type类的__init__方法进行定制，可以创建一个type的子类，并自行定义__init__方法，之后再创建类的时候，
## 使用metaclass来指定由type的子类来创建类，不再使用默认的type类

class MyType(type):
    def __init__(self, *args, **kwargs):
        print('I am __init__ of MyType')

    def __call__(self, *args, **kwargs):
        r = self.__new__()

class Foo(metaclass=MyType):  ## 代码运行到这的时候,其实是创建了一个MyType类的对象，对象名字为Foo,
                              ## 创建对象时会自动调用类的__init__方法，所以MyType的__init__方法被执行
    def bar(self):
        print('I am bar of Foo')

    def __new__(cls, *args, **kwargs):
        return

#obj = Foo() # 代码执行到这的时候，会先执行MyType类的__call__方法，因为Foo是MyType类的对象，
            # 对象后加括号调用的是该对象的类的__call__方法
#obj.bar()


#### 通过类创建一个对象obj = Foo()的过程####

# 1. 执行type的__call__ (因为Foo本身也是一个对象，对象后加括号调用的是其所属类的__call__方法)

# 2. __call__调用Foo的__new__方法，__new__方法创建一个对象，并返回给__call__

# 3. __call__调用Foo的__init__方法(self.__init__)，并将上一步__new__创建的对象做为参数传入，初始化了该对象的属性


