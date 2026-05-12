from django.urls import path
from . import views
app_name='consultations'
urlpatterns=[path('',views.consult_list,name='list'),
             path('new/',views.consult_create,name='create'),
             path('<int:pk>/',views.consult_detail,name='detail'),
             path('vitals/<int:patient_id>/',views.vitals_create,name='vitals_create')]
