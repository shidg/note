#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

from random import randint

class Die():
    def __init__(self,sides=6):
        self.sides = sides

    def roll_die(self):
        print(self.sides)

my_die = Die()

for i in range(1,7):
    my_die.sides = randint(1,6)
    my_die.roll_die()


