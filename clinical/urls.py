from django.urls import path
from . import views
urlpatterns=[path('', views.clinical_home, name='clinical_home'), path('lab/<int:test_id>/result/', views.lab_result, name='lab_result')]
