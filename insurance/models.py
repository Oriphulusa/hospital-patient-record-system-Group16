from django.db import models
from patients.models import Patient


class InsuranceProvider(models.Model):
    name = models.CharField(max_length=120, unique=True)

    contact = models.CharField(
        max_length=120,
        blank=True
    )

    coverage_percent = models.PositiveIntegerField(
        default=0,
        help_text='Default % covered'
    )

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'insurance_insuranceprovider'


class PatientInsurance(models.Model):
    patient = models.ForeignKey(
        Patient,
        on_delete=models.CASCADE,
        related_name='insurances'
    )

    provider = models.ForeignKey(
        InsuranceProvider,
        on_delete=models.PROTECT
    )

    policy_number = models.CharField(max_length=80)

    coverage_percent = models.PositiveIntegerField(
        default=0,
        help_text='Override; 0 = use provider default'
    )

    valid_until = models.DateField(
        null=True,
        blank=True
    )

    is_active = models.BooleanField(default=True)

    def effective_coverage(self):
        return (
            self.coverage_percent
            or self.provider.coverage_percent
        )

    def __str__(self):
        return f'{self.patient} - {self.provider.name}'

    class Meta:
        db_table = 'insurance_patientinsurance'