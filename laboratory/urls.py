from django.urls import path
from . import views
app_name='laboratory'
urlpatterns=[path('tests/',views.test_list,name='test_list'),
             path('tests/new/',views.test_create,name='test_create'),
             path('order/<int:consultation_id>/',views.order_create,name='order_create'),
             path('result/<int:pk>/',views.order_complete,name='order_complete')]
