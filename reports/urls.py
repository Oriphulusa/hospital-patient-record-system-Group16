from django.urls import path
from . import views
urlpatterns=[
    path('dashboard/', views.dashboard, name='dashboard'),
    path('sql-demo/', views.sql_demo, name='sql_demo'),
    path('database-proof/', views.database_proof, name='database_proof'),
    path('api/dashboard/', views.api_dashboard, name='api_dashboard'),
    path('api/patients/', views.api_patients, name='api_patients'),
    path('api/appointments/', views.api_appointments, name='api_appointments'),
]
