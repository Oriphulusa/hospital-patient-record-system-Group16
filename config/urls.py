from django.urls import path, include
from common import views as common_views
urlpatterns = [
    path('', common_views.landing, name='landing'),
    path('', include('accounts.urls')),
    path('', include('reports.urls')),
    path('patients/', include('patients.urls')),
    path('appointments/', include('appointments.urls')),
    path('clinical/', include('clinical.urls')),
    path('wards/', include('wards.urls')),
    path('billing/', include('billing.urls')),
]
