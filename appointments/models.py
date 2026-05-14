from django.db import models
from django.conf import settings
from patients.models import Patient

class Appointment(models.Model):
    STATUS=[('scheduled','Scheduled'),('completed','Completed'),('cancelled','Cancelled'),('no_show','No Show')]
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='appointments')
    doctor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='doctor_appointments', limit_choices_to={'role':'doctor'})
    scheduled_for = models.DateTimeField()
    reason = models.CharField(max_length=200)
    status = models.CharField(max_length=15, choices=STATUS, default='scheduled')
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        ordering=['-scheduled_for']
        managed = False
        db_table = 'appointments_appointment'
    def __str__(self): return f'{self.patient} with Dr. {self.doctor.get_full_name() or self.doctor.username}'
