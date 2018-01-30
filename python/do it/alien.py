#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
my_friends = {
    'name': 'js',
    'age': 37,
    'city': 'BeiJing',
    'alias': 'laji',
    }
print(my_friends['name'] + ",s age is " + str(my_friends['age']) +
    ", " + "He is in " + my_friends['city'] + ".")

user_0 = {
    'username': 'efermi',
    'first': 'enrico',
    'last': 'fermi',
    }
for key,value in user_0.items():
    print("Key: " + key)
    print("Value: " + value + "\n")


print("-----------------------------------------------------------\n")

favorite_languages = {
    'jen': 'python',
    'sarah': 'c',
    'edward': 'ruby',
    'phil': 'python',
    'alen': 'php',
    }

for key,value in favorite_languages.items():
    print("Key: " + key + "; " + "Value: " + value + ".")

for name in favorite_languages.keys():
    print("Name: " + name)

for language in favorite_languages.values():
    print("Languages: " + language)


for key,value in favorite_languages.items():
    print(key + "'s favorite language is " + value + ".\n")

print("==============================================")

for key in favorite_languages.keys():
    print(key)

print("==============================================")
for key in sorted(favorite_languages.keys()):
    print(key)

print("===============================================")

for value in set(favorite_languages.values()):
    print(value)

print("-----------------------------------------------")
for key in favorite_languages:
    print(key)
