from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = 'dev-insecure-change-me'
DEBUG = True
ALLOWED_HOSTS = ['*']
INSTALLED_APPS = [
    'django.contrib.admin','django.contrib.auth','django.contrib.contenttypes',
    'django.contrib.sessions','django.contrib.messages','django.contrib.staticfiles',
    'accounts','patients','appointments','consultations','pharmacy',
    'laboratory','wards','billing','insurance','dashboard',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
ROOT_URLCONF = 'hospital_system.urls'
TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [BASE_DIR / 'templates'],
    'APP_DIRS': True,
    'OPTIONS': {'context_processors': [
        'django.template.context_processors.debug','django.template.context_processors.request',
        'django.contrib.auth.context_processors.auth','django.contrib.messages.context_processors.messages',
        'accounts.context_processors.role_context',
    ]},
}]
WSGI_APPLICATION = 'hospital_system.wsgi.application'
import os as os_os
DATABASES = {
    'default':{
        'ENGINE': 'django.db.backend.postgresql',
        'NAME':     os_os.environ.get('DB_NAME',     'hospital_db'),
        'USER':     os_os.environ.get('DB_USER'      'postgres'),
        'PASSWORD': os_os.environ.get('DB_PASSWORD', 'postgres'),
        'HOST':     os_os.environ.get('DB_HOST',     'localhost'),
        'PORT':     os_os.environ.get('DB_PORT',     '5432'),
    }
}
AUTH_USER_MODEL = 'accounts.User'
LANGUAGE_CODE = 'en-us'; TIME_ZONE = 'UTC'; USE_I18N = True; USE_TZ = True
STATIC_URL = 'static/'; STATICFILES_DIRS = [BASE_DIR / 'static']
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
LOGIN_URL = '/accounts/login/'
LOGIN_REDIRECT_URL = '/dashboard'
LOGOUT_REDIRECT_URL = '/'
