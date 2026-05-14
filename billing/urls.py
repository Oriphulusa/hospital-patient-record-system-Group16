from django.urls import path
from . import views
app_name='billing'
urlpatterns=[path('',views.bill_list,name='list'),
             path('new/',views.bill_create,name='create'),
             path('<int:pk>/',views.bill_detail,name='detail'),
             path('<int:pk>/items/',views.add_item,name='add_item'),
             path('<int:pk>/payments/',views.add_payment,name='add_payment')]
