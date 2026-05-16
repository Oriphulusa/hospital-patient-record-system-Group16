from django.db import models
from django.conf import settings


class Patient(models.Model):
    GENDER = [
        ('M', 'Male'),
        ('F', 'Female'),
        ('O', 'Other')
    ]

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='patient_profile'
    )

    mrn = models.CharField(
        'Medical Record No.',
        max_length=20,
        unique=True
    )

    first_name = models.CharField(max_length=80)
    last_name = models.CharField(max_length=80)
    date_of_birth = models.DateField()

    gender = models.CharField(
        max_length=1,
        choices=GENDER
    )

    phone = models.CharField(max_length=30, blank=True)
    address = models.TextField(blank=True)
    blood_group = models.CharField(max_length=5, blank=True)
    emergency_contact = models.CharField(max_length=120, blank=True)
    allergies = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.mrn} - {self.first_name} {self.last_name}'

    def full_name(self):
        return f'{self.first_name} {self.last_name}'

    class Meta:
        db_table = 'patients_patient'