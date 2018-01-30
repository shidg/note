#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
#def greet_user(username):
#    """显示简单的问候语"""
#    print("Hello!" + username.title() + "!")

#greet_user('jerry')

def greet_users(names):
    """向列表中的每位用户都发出问候"""
    for name in names:
        msg = "Hello " + name.title() + "!"
        print(msg)

usernames = ['harry','tony','hilen']

greet_users(usernames)

