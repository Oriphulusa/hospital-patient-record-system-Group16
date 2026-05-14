from django.contrib import admin
from django.urls import path, include
urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('patients/', include('patients.urls')),
    path('appointments/', include('appointments.urls')),
    path('consultations/', include('consultations.urls')),
    path('pharmacy/', include('pharmacy.urls')),
    path('laboratory/', include('laboratory.urls')),
    path('wards/', include('wards.urls')),
    path('billing/', include('billing.urls')),
    path('insurance/', include('insurance.urls')),
    path('', include('dashboard.urls')),
]
