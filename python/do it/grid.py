#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

def do_twice(f):
    f()
    f()

def do_four(f):
    do_twice(f)
    do_twice(f)

def print_beam():
    print('+--------', end='')

def print_beams():
    #do_twice(print_beam)
    do_four(print_beam)
    print('+')

def print_post():
    print('|        ', end='')

def print_posts():
    #do_twice(print_post)
    do_four(print_post)
    print('|')

def print_row():
    print_beams()
    do_four(print_posts)

# def print_grid():
    #do_twice(print_row)
#    do_four(print_row)
#    print_beams()
#print_grid()

def print_grid(func,arg):
    func(arg)

print_grid(do_four,print_row)
print_beams()

#do_twice(print_row)
#do_four(print_row)
#print_beams()

#print('+', end='')
#print('-')
