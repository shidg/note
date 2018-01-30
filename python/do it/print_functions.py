#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

def print_models(unprinted_designs,completed_models):
    """
    模拟打印每个设计，知道没有未打印的设计为止
    打印每个设计后，将其移动到列表completed_models中
    """
    while unprinted_designs:
        #每次取出一个元素
        current_design = unprinted_designs.pop()

        # 模拟根据设计制作3D打印模型的过程
        print("Printing model: " + current_design)
        completed_models.append(current_design)


def show_completed_models(completed_models):
    """显示打印好的模型"""

    print("\nThe following models have been printed:")
    for completed_model in completed_models:
        print(completed_model)
