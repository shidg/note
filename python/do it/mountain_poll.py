#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

#设置一个空字典
responses = {}

# 设置一个标志
polling_active = True

while polling_active:
    #提示输入被调查者的名字和回答
    name = input("\nWhat is your name? ")
    response = input("\nWhich mountain would you like to climb comeday? ")

    # 将答卷存储在字典中
    responses[name] = response

    #看是否还有人要参与调查
    repeat = input("Would you like to let another person respond? (yes/no)")
    if repeat == 'no':
        polling_active = False

#调查结束，显示结果
print("\n---Poll Results ---")
for name,response in responses.items():
    print(name + " would like to climb " + response + ".")


