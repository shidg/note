#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
class Restaurant():
    """对餐馆的描述"""
    def __init__(self,rname,rtype):
        self.restaurant_name = rname
        self.cuisine_type = rtype

    def describe_restaurant(self):
        print("The restaurant's name is " + self.restaurant_name.title() + ".")
        print("The restaurant's type is " + self.cuisine_type.title() + ".")

    def open_restaurant(self):
        print("The restaurant is in service")

my_restaurant = Restaurant('KFC','kuaican')

my_restaurant.describe_restaurant()
