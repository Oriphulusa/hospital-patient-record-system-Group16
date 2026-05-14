from django.urls import path
from . import views
app_name='wards'
urlpatterns=[path('',views.ward_list,name='list'),
             path('new/',views.ward_create,name='ward_create'),
             path('beds/new/',views.bed_create,name='bed_create'),
             path('admit/',views.admit,name='admit'),
             path('discharge/<int:pk>/',views.discharge,name='discharge')]
