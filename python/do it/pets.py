#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
#def describe_pet(animal_type,pet_name):
def describe_pet(pet_name,animal_type='dog'):
    """显示宠物信息"""
    print("\nI have a " + animal_type + ".")
    print("\nMy " + animal_type + "'s name is " + pet_name.title() + ".")

#describe_pet('tom','cat')
def get_formatted_name(first_name,last_name):
    """返回整洁的姓名"""
    full_name = first_name + ' ' + last_name
    return full_name.title()

musician = get_formatted_name('jimi','hendrix')
print(musician)
