#!/usr/local/bin/python3
# -*- coding: utf-8 -*-#
'''
author: -- shidegang --
Created Time: 2019-08-26 21:27:29
'''
product_list = [
    ('mac',9000),  
    ('book',90),        
    ('bike',800)        
]

saving = input("Please input your money: ")
shopping_car = []
if saving.isdigit():
    saving = int(saving)

    while True:
        for i,v in enumerate(product_list,1):
            print(i,'>>>>',v)
        choice = input("选择购买商品的编号,Q退出")
        if choice.isdigit():
            choice = int(choice)
            if choice>0 and choice<=len(product_list):
                p_item = product_list[choice-1]
                if p_item[1] < saving:
                    saving -= p_item[1]
                    shopping_car.append(p_item[0])
                else:
                    print("余额不足，还剩%s元"%saving)
            else:
                print("编码不存在")
        elif choice == 'q':
            print("您已购买如下商品:")
            for i in shopping_car:
                print(i)
            print("您还剩%s元钱"%saving)
            break
        else:
            print("编码格式不正确")
            break
else:
    print("别乱输入")
