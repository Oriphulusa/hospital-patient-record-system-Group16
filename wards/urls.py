from django.urls import path
from . import views
urlpatterns=[path('', views.ward_list, name='ward_list')]
