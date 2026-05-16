from django.db import models
from consultations.models import Consultation

class LabTest(models.Model):
    name = models.CharField(max_length=120, unique=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    class Meta:
        managed = False
        db_table = 'laboratory_labtest'

    def __str__(self):
        return self.name

class LabOrder(models.Model):
    STATUS = [('ordered', 'Ordered'), ('completed', 'Completed')]
    consultation = models.ForeignKey(Consultation, on_delete=models.CASCADE, related_name='lab_orders')
    test = models.ForeignKey(LabTest, on_delete=models.PROTECT)
    status = models.CharField(max_length=15, choices=STATUS, default='ordered')
    result = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'laboratory_laborder'