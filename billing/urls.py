from django.urls import path
from . import views
urlpatterns=[path('', views.billing_list, name='billing_list'), path('<int:billing_id>/pay/', views.record_payment, name='record_payment')]
