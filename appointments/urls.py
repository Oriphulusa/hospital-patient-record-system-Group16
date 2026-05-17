from django.urls import path
from . import views
urlpatterns=[
    path('', views.appointment_list, name='appointment_list'),
    path('new/', views.appointment_new, name='appointment_new'),
    path('<int:appointment_id>/status/', views.appointment_status, name='appointment_status'),
]
