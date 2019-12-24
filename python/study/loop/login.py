#!/usr/bin/python
# -*- coding: utf-8 -*- #
username = input("请输入姓名: ")

with open('blocked_users', 'r') as f_obj:
    f = f_obj.readlines()
    user_list = []
    for u in f:
        user_list.append(u.rstrip())

if username in user_list:
    print("对不起，由于多次输入错误密码，该账号已被锁定")
else:
    err_auth = 0
    try_times = 3
    while True:
        password = input("请输入密码: ")

        if password == "123456":
            print("Welcome!")
            break
        else:
            err_auth += 1
            try_times -= 1
            if int(err_auth) < 3:
                print("密码错误!")
                print("还可以尝试" + str(try_times) + "次")
            else:
                with open('blocked_users', 'a') as f_obj:
                    f_obj.write(username + "\n")
                print("账号已被锁定!")
                break
