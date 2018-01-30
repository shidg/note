#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
squares = []
for value in range(1,11):
    square = value**2
    squares.append(square)
print(squares)

print("###########################")

squares_1 = list(range(1,11))
print(squares_1)

print(sum(squares))

squares = [value**2 for value in range(10,21)]
print(squares)

#for value in range(1,21):
#    print(value)

print("###########################")

squares = [value for value in range(1,1000001)]
print(min(squares))
print(max(squares))
print(sum(squares))

print("###########################")

squares = [value for value in range(1,20,2)]
print(squares)

print("###########################")
squares = [value**3 for value in range(1,11)]
print(squares)

print("###########################")

print(squares[:3])
print(squares[-3:])
squares_1 = squares[:]
print(squares_1)

print("########################################")
squares = (100,200)
print(squares)
print(squares[0])
squares = (200,300)
print(squares[0])
