#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
from dog import Dog
my_dog = Dog('willie',6)

print("My dog's name is " + my_dog.name.title() + ".")

my_dog.sit()

my_dog.roll_over()
