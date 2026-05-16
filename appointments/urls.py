from django.urls import path
from . import views
app_name='appointments'
urlpatterns=[path('',views.appointment_list,name='list'),
             path('new/',views.appointment_create,name='create'),
             path('<int:pk>/edit/',views.appointment_edit,name='edit')]
             
