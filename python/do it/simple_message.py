#!/usr/local/python3/bin/python3
# -*- coding: utf-8 -*-
def get_formatted_name(first_name,last_name):
    """返回格式化的姓名"""
    full_name = first_name + '' + last_name 
    return full_name.title()

#这是一个无限循环
while True:
    print("\nPlease tell me your name:")
    print("Enter 'q' to exit")
    f_name = input("First name: ")
    if f_name == 'q':
        break
    l_name = input("Last name: ")
    if l_name == 'q':
        break
        
    formatted_name = get_formatted_name(f_name,l_name)
    print("\nHello, " + formatted_name + "!")
