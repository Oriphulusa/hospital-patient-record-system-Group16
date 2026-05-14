from django.urls import path
from . import views
app_name='insurance'
urlpatterns=[path('',views.provider_list,name='provider_list'),
             path('providers/new/',views.provider_create,name='provider_create'),
             path('policies/new/',views.policy_create,name='policy_create')]
