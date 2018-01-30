#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
import time

def countdown(n):
    if n < 1:
        #print("Blastoff!")
        pass
    else:
        print(n)
        countdown(n-1)

#countdown(5)

def print_n(s, n):
    if n <= 0:
        return
    else:
        print(s)
        print_n(s, n-1)
#s = "Python is good"
#n = 4
#print_n(s, n)


current_time = time.time()
days = current_time / 86400 
left_days = current_time % 86400

hours = left_days // 3600
left_hours = left_days % 3600
minus = left_hours // 60
print(current_time)
print(days)
print(left_days)

print(hours)
print(minus)
