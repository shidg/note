#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

#import print_functions
#from print_functions import print_models,show_completed_models
#from print_functions import *
#import print_functions as f
from print_functions import print_models as p
from print_functions import show_completed_models as s

unprinted_designs = ['iphone case','robot pendant','dodecahedron']
completed_models = []


p(unprinted_designs,completed_models)
s(completed_models)
