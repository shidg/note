#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

#class Car():
#    def __init__(self,make,modle,year):
#        self.make = make
#        self.modle = modle
#        self.year = year
#        self.odometer_reading = 0
#
#    def get_descriptive_name(self):
#        long_name = str(self.year) + ' ' + self.make + ' ' + self.modle
#        return long_name.title()
#
#    def read_odometer(self):
#        print('This car has {} miles on it'.format(str(self.odometer_reading)))
#
#    def update_odometer(self,mileage):
#        if mileage >= self.odometer_reading:
#            self.odometer_reading = mileage
#        else:
#            print('You can not roll back an odometer!')
#
#    def increment_odometer(self,miles):
#        self.odometer_reading += miles
#
#class ElectricCar(Car):
#    def __init__(self,make,modle,year):
#        super().__init__(make,modle,year)
#        self.battery_size = 70
#
#my_tesla = ElectricCar('tesla','model s',2016)
#
#print(my_tesla.get_descriptive_name())
#
#my_tesla.update_odometer(4)
#
#my_tesla.update_odometer(5)
#
#my_tesla.read_odometer()
#
#print(my_tesla.battery_size)


#####
# python支持多继承，即一个子类可以有多个父类

class A():
    def foo(self):
        print('okA')
class B(A):
    def foo(self):
        print('okB')

class C():
    def foo(self):
        print('okC')
class D(C):
    def foo(self):
        print('okD')

class E(C,B):
    def foo(self):
        print('okE')

obj = E()  # 如果class E中没有foo方法，则执行父类C中的，C中没有则执行C的父类中的，C的父类中也没有则执行B中的，
           # 多继承的时候，按照继承顺序从左到右查找，并且左边查询完之后才会查询右边
obj.foo()
