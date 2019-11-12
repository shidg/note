#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-28 10:43:17
'''

class Menu():
    def __init__(self,name = 'nobody'):
        self.name = name
    def display_menu_list(self):
        print("""
        1. 首页
        2. 金融
        3. 书城
        """)


def login_check(auth_type):
    def login(func):
        def wrapper():
            global login_status
            if not login_status:
                print('请登录')
                username = input('用户名： ')
                passwd = input('密码')
                if auth_type == 'jingdong':
                    print('你使用京东账号登录成功')
                else:
                    print('你使用微信账号登录成功')
            func()
            login_status = True
        return wrapper
    return login

@login_check('jingdong')
def home():
    print('welcome to home')

@login_check('weixin')
def finance():
    print('welcome to finance')

@login_check('jingdong')
def book():
    print('welcome to book')

login_status = False

choices = {
    '1':home,
    '2':finance,
    '3':book
}
choices = {
    '1':home,
    '2':finance,
    '3':book
}

if __name__ == '__main__':
    while True:
        Menu().display_menu_list()
        choice = input('输入编号选择要去到的页面')
        if choice in choices:
            action = choices.get(choice)
            action()
        elif choice == 'q':
            break
        else:
            print('{0} is not a valid choice.'.format(choice))
