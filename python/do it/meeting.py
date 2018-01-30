#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
peples = ['toma','tomb','tomc']
print(peples[0] + " " + peples[1] + " " + peples[2] + ", please come to my home!")

for peple in peples:
    print(peple + ", please come to my home!")

cant_peple = peples[0]
#peples[0] = 'tom8'
print("Sorry, " + cant_peple +" can't come",peples[0] + "instead\nNow,the list is: ")
print(peples)


peples.insert(0,'tome')
peples.insert(3,'tomf')
peples.append('tomg')
print("=====================================================================")
print("Now,the meeting list is: ")
print(peples)


print("But, I am so sorry")
sorry_list = []

for peple in peples:
    print(peple)
    if peple == "tomb":
        pass
    else:
        peples.remove(peple)
        print(peple + " can't come")
        sorry_list.append(peple)

print("Ths sorry list is:")
print(sorry_list)

print("Now,meeting list is: ")
print(peples)
