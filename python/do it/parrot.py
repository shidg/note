#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
prompt = "If you tell us who you are,we can personalize the message you see."
prompt += "\nWhat is your name? "

active = True
while active:
    message = input(prompt)
    if message == 'quit':
        active = False
    else:
        print(message)
