#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
class Dog():
    """一次模拟小狗的简单尝试"""
    def __init__(self,name,age):
        """初始化属性name和age"""
        self.name = name
        self.age = age

    def sit(self):
        """模拟小狗被命令蹲下"""
        print(self.name.title() + " is now sitting.")

    def roll_over(self):
        """模拟小狗被命令打滚"""
        print(self.name.title() + " rolled over!")

