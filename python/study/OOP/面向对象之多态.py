#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Animal(object):
    def run(self):
        print('Animal is running...')

class Dog(Animal):
    def run(self):
        print('Dog is running...')


class Cat(Animal):
    def run(self):
        print('Cat is running...')


class Tortoise(Animal):
    def run(self):
        print('Tortoise is running...')


class Duck(object):
    def run(self):
        print('duck is swiming...')
dog = Dog()
cat = Cat()

#print(isinstance(dog,Dog))
#print(isinstance(cat,Cat))

def run_twice(animal):
    animal.run()
    animal.run()

run_twice(Animal())
run_twice(Dog())
run_twice(Cat())
run_twice(Tortoise())
run_twice(Duck())

#与java/c++等语言相比，python原生支持多态

对于一个变量，我们只需要知道它是Animal类型，无需确切地知道它的子类型，就可以放心地调用run()方法，而具体调用的run()方法是作用在Animal、Dog、Cat还是Tortoise对象上，由运行时该对象的确切类型决定，这就是多态真正的威力：调用方只管调用，不管细节，而当我们新增一种Animal的子类时，只要确保run()方法编写正确，不用管原来的代码是如何调用的。这就是著名的“开闭”原则：

对扩展开放：允许新增Animal子类；

对修改封闭：不需要修改依赖Animal类型的run_twice()等函数。


## 鸭子类型：
还以上边的代码为示例，甚至都不是必须要传出Animal类型的数据，只要传入的数据有run()方法，run_twice()就可以正常运行，
这就是动态语言的“鸭子类型”，它并不要求严格的继承体系，一个对象只要“看起来像鸭子，走起路来像鸭子”，那它就可以被看做是鸭子。

Python的“file-like object“就是一种鸭子类型。对真正的文件对象，它有一个read()方法，返回其内容。但是，许多对象，只要有read()方法，都被视为“file-like object“。许多函数接收的参数就是“file-like object“，你不一定要传入真正的文件对象，完全可以传入任何实现了read()方法的对象。
