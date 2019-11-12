#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-27 10:03:25
'''
import json

filename = 'f.json'
with open(filename,'r') as f_obj:
    menu = json.load(f_obj)
#    menu = eval(f_obj.read())

last_layer = []
current_layer = menu
exit_flag = False

while not exit_flag:
    for key in current_layer:
        print(key)
    print()
    choice = input('输入你想去的地方,按q退出程序\n >>> :')
    if len(choice) == 0:
        continue
    elif choice in current_layer:
        last_layer.append(current_layer)
        try:
            current_layer = current_layer[choice]
            print('current_layer: ',current_layer)
        except TypeError:
            print('已是最后一层，无法再展开,按b返回上一层')
            last_layer.pop()
    elif choice == 'n':
        new_name = input('输入新增的地名:')
        current_layer.append(new_name)
        print('current_layer:',current_layer)
    elif choice == 'b':
        if last_layer:
            current_layer = last_layer.pop()
        else:
            print('已达最上层，请重新选择')
    elif choice == 'q':
        exit_flag = True
