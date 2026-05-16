from django.db import models
from django.conf import settings
from patients.models import Patient


class Ward(models.Model):
    name = models.CharField(max_length=80, unique=True)
    description = models.CharField(max_length=200, blank=True)
    daily_rate = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0
    )

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'wards_ward'


class Bed(models.Model):
    ward = models.ForeignKey(
        Ward,
        on_delete=models.CASCADE,
        related_name='beds'
    )

    number = models.CharField(max_length=10)
    is_occupied = models.BooleanField(default=False)

    class Meta:
        unique_together = ('ward', 'number')
        db_table = 'wards_bed'

    def __str__(self):
        return f'{self.ward.name} - Bed {self.number}'


class Admission(models.Model):
    patient = models.ForeignKey(
        Patient,
        on_delete=models.CASCADE,
        related_name='admissions'
    )

    bed = models.ForeignKey(
        Bed,
        on_delete=models.PROTECT,
        related_name='admissions'
    )

    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='admissions',
        limit_choices_to={'role': 'doctor'}
    )

    reason = models.CharField(max_length=200)

    admitted_at = models.DateTimeField(auto_now_add=True)

    discharged_at = models.DateTimeField(
        null=True,
        blank=True
    )

    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['-admitted_at']
        db_table = 'wards_admission'

    @property
    def is_active(self):
        return self.discharged_at is None