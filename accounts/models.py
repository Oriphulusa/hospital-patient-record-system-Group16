from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = 'admin', 'Admin / Receptionist'
        DOCTOR = 'doctor', 'Doctor'
        NURSE = 'nurse', 'Nurse'
        PATIENT = 'patient', 'Patient'

    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.PATIENT
    )

    phone = models.CharField(max_length=30, blank=True)

    specialization = models.CharField(
        max_length=120,
        blank=True,
        help_text='For doctors'
    )

    def is_admin(self):
        return self.role == self.Role.ADMIN or self.is_superuser

    def is_doctor(self):
        return self.role == self.Role.DOCTOR

    def is_nurse(self):
        return self.role == self.Role.NURSE

    def is_patient(self):
        return self.role == self.Role.PATIENT

    class Meta:
        db_table = 'accounts_user'