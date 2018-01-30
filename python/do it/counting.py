#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
current_number = 1
while current_number <= 5:
    print(current_number)
    current_number += 1

prompt = "\nTell me something,and I will repeat it back to you: "
prompt += "\nEnter 'quit' to end the program. "
message = ""
#while message != 'quit':
#    message = input(prompt)
#    print(message)

while True:
    message = input(prompt)
    if message == 'quit':
        break
    else:
        print(message)


x = 1
while x <= 5:
    print(x)
    x += 1
