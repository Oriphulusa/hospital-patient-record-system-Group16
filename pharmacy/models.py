from django.db import models
from consultations.models import Consultation

class Medication(models.Model):
    name = models.CharField(max_length=120, unique=True)
    description = models.TextField(blank=True)
    stock = models.PositiveIntegerField(default=0)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    def __str__(self): return self.name

class Prescription(models.Model):
    consultation = models.ForeignKey(Consultation, on_delete=models.CASCADE, related_name='prescriptions')
    medication = models.ForeignKey(Medication, on_delete=models.PROTECT)
    dosage = models.CharField(max_length=80, help_text='e.g. 500mg')
    frequency = models.CharField(max_length=80, help_text='e.g. 3x daily for 5 days')
    quantity = models.PositiveIntegerField(default=1)
    dispensed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self): return f'{self.medication} x{self.quantity}'
