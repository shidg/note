#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-26 15:16:03
'''
import time
import sys


class Things():
    def __init__(self, username='nobody'):
        self.username = username

    def clean_disk(self):
        print("cleaning disk ... ...")
        time.sleep(1)
        print("clean disk done!")

    def clean_dir1(self):
        print("cleaning dir1 ... ...")
        time.sleep(1)
        print("clean dir1 done!")

    def clean_dir2(self):
        print("cleaning dir2 ... ...")
        time.sleep(1)
        print("clean dir2 done!")
    def show_user(self):
        print("username:", self.username)


class Menu(Things):
    def __init__(self):
        super().__init__()
        self.choices = {
            "1": self.clean_disk,
            "2": self.clean_dir1,
            "3": self.clean_dir2,
            "4": self.show_user,
            "5": self.quit
        }

    def display_menu(self):
        print("""
Operation Menu:
1. Clean disk
2. Clean dir1
3. Clean dir2
4. Show user
5. Quit
""")

    def run(self):
        while True:
            self.display_menu()
    #        try:
            choice = input("Enter an option: ")
    #       except Exception as e:
    #            print("Please input a valid option!");continue

            choice = str(choice).strip()
            action = self.choices.get(choice)
            if action:
                action()
            else:
                print("{0} is not a valid choice".format(choice))
#                print("%s is not a valid choice"%choice)

    def quit(self):
        print("\nThank you for using this script!\n")
        sys.exit(0)


if __name__ == '__main__':
    Menu().run()
