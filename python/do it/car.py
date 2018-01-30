#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

class Car():
    """一次模拟汽车的尝试"""
    def __init__(self,make,model,year):
        """初始化汽车的属性"""
        self.make = make
        self.model = model
        self.year = year
        self.odometer_reading = 0

    def get_descriptive_name(self):
        """返回整洁的描述信息"""
#        print(str(self.year) + ' ' + self.make + ' ' + self.model)
        long_name = str(self.year) + ' ' + self.make + ' ' + self.model
        return long_name.title()

    def read_odometer(self):
        """打印汽车里程"""
        print("This car has " +  str(self.odometer_reading) + " miles on it.")

    def update_odometer(self,mileage):
        """将里程表读书修改为指定的值"""
        if mileage >= self.odometer_reading:
            self.odometer_reading = mileage
        else:
            print("You can't roll back an odometer!")
    
    def increment_odometer(self,miles):
        """将里程表增加指定的读数"""
        self.odometer_reading += miles

my_new_car = Car('audi','a4','2016')

print(my_new_car.get_descriptive_name())

my_new_car.update_odometer(130)

my_new_car.read_odometer()

my_used_car = Car('subaru','outback','2013')
print(my_used_car.get_descriptive_name())

my_used_car.update_odometer(23500)
my_used_car.read_odometer()

my_used_car.increment_odometer(100)
my_used_car.read_odometer()


class Battery():
    def __init__(self,battery_size=70):
        self.battery_size = battery_size

    def describe_battery(self):
        print("This car has a " + str(self.battery_size) + "-kWh battery.")

    def get_range(self):
        if self.battery_size == 70:
            range = 240
        elif self.battery_size == 85:
            range = 270
        message = "This car can go approximately " + str(range)
        message += " miles on a full charge."
        print(message)

class ElectricCar(Car):
    def __init__(self,make,model,year):
        """电动汽车的独特之处
        先初始化父类的属性，再初始化电动汽车的特有属性
        """
        super().__init__(make,model,year)

        self.battery = Battery()

my_tesla = ElectricCar('tesla','model s','2016')
print(my_tesla.get_descriptive_name())
my_tesla.battery.describe_battery()
my_tesla.battery.get_range()
