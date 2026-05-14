from django.urls import path
from . import views
app_name='pharmacy'
urlpatterns=[path('meds/',views.med_list,name='med_list'),
             path('meds/new/',views.med_create,name='med_create'),
             path('prescribe/<int:consultation_id>/',views.prescribe,name='prescribe'),
             path('dispense/<int:pk>/',views.dispense,name='dispense')]
