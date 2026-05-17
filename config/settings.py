import os
from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.getenv('SECRET_KEY','dev-secret-for-hprs-phase3')
DEBUG = os.getenv('DEBUG','True').lower() == 'true'
ALLOWED_HOSTS = ['127.0.0.1','localhost']
INSTALLED_APPS = [
    'django.contrib.staticfiles',
    'common','accounts','patients','appointments','clinical','wards','billing','reports',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
]
ROOT_URLCONF='config.urls'
TEMPLATES=[{
    'BACKEND':'django.template.backends.django.DjangoTemplates',
    'DIRS':[BASE_DIR/'templates'],
    'APP_DIRS':True,
    'OPTIONS':{'context_processors':['django.template.context_processors.request','common.context_processors.current_staff']},
}]
WSGI_APPLICATION='config.wsgi.application'
DATABASES={
    'default':{
        'ENGINE':'django.db.backends.postgresql',
        'NAME':os.getenv('DB_NAME','hprs_phase3_db'),
        'USER':os.getenv('DB_USER','postgres'),
        'PASSWORD':os.getenv('DB_PASSWORD',''),
        'HOST':os.getenv('DB_HOST','localhost'),
        'PORT':os.getenv('DB_PORT','5432'),
    }
}
# No Django ORM hospital schema and no Django session table required.
# Sessions are stored in signed cookies so the DB can remain exactly your PostgreSQL Phase 3 schema.
SESSION_ENGINE='django.contrib.sessions.backends.signed_cookies'
LANGUAGE_CODE='en-us'
TIME_ZONE='Africa/Johannesburg'
USE_I18N=True
USE_TZ=True
STATIC_URL='/static/'
STATICFILES_DIRS=[BASE_DIR/'static']
DEFAULT_AUTO_FIELD='django.db.models.BigAutoField'
# Email defaults to console. Gmail SMTP can be enabled using environment variables.
EMAIL_BACKEND=os.getenv('EMAIL_BACKEND','django.core.mail.backends.console.EmailBackend')
EMAIL_HOST=os.getenv('EMAIL_HOST','smtp.gmail.com')
EMAIL_PORT=int(os.getenv('EMAIL_PORT','587'))
EMAIL_USE_TLS=os.getenv('EMAIL_USE_TLS','True').lower() == 'true'
EMAIL_HOST_USER=os.getenv('EMAIL_HOST_USER','')
EMAIL_HOST_PASSWORD=os.getenv('EMAIL_HOST_PASSWORD','')
DEFAULT_FROM_EMAIL=os.getenv('DEFAULT_FROM_EMAIL', EMAIL_HOST_USER or 'hprs@hospital.local')
