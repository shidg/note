#!/usr/bin/env python
# -*- coding: utf-8 -*-#
'''
@Author: --- shidg ---
@Created at: 2019-12-25 11:50:07
@Version: 
@Modify by: 
'''
from django import forms
from .models import Topic, Entry
class TopicForm(forms.ModelForm):
    class Meta:
        model = Topic
        fields = ['text']
        labels = {'text':''}

class EntryForm(forms.ModelForm):
    class Meta:
        model = Entry
        fields = ['text']
        labels = {'text': ''}
        widgets = {'text': forms.Textarea(attrs={'cols': 80})}

