"""learning_log URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import path,re_path
from . import views

app_name = 'learning_logs'
urlpatterns = [
    re_path('^$', views.index,name='index'),
    re_path('^topic/$', views.topics,name='topics'),
    re_path(r'^topics/(?P<topic_id>\d+)/$', views.topic,name='topic'),
    re_path(r'^new_topic/$', views.new_topic,name='new_topic'),
    re_path(r'^new_entry/(?P<topic_id>\d+)/$', views.new_entry,name='new_entry'),
    re_path(r'^edit_entry/(?P<entry_id>\d+)/$', views.edit_entry,name='edit_entry'),
]
