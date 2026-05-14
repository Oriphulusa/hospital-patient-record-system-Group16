from django.urls import path
from django.contrib.auth import views as av
from . import views
app_name = 'accounts'
urlpatterns = [
    path('login/', av.LoginView.as_view(template_name='accounts/login.html'), name='login'),
    path('logout/', av.LogoutView.as_view(), name='logout'),
    path('users/', views.user_list, name='user_list'),
    path('users/new/', views.user_create, name='user_create'),
]
