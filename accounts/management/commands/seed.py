from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from datetime import date, timedelta
from django.utils import timezone
from patients.models import Patient
from appointments.models import Appointment
from pharmacy.models import Medication
from laboratory.models import LabTest
from wards.models import Ward, Bed
from insurance.models import InsuranceProvider

User = get_user_model()

class Command(BaseCommand):
    help='Seed demo data'
    def handle(self, *a, **k):
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser('admin','admin@example.com','password123',
                role='admin', first_name='Sys', last_name='Admin')
        def mk(username, role, **extra):
            u, created = User.objects.get_or_create(username=username,
                defaults={'role':role, **extra})
            if created:
                u.set_password('password123'); u.save()
            return u
        d1 = mk('doctor1','doctor',first_name='Aisha',last_name='Khan',specialization='General Medicine')
        n1 = mk('nurse1','nurse',first_name='Mark',last_name='Lee')
        p1u = mk('patient1','patient',first_name='Jane',last_name='Doe',email='jane@example.com')

        if not Patient.objects.filter(mrn='MRN0001').exists():
            Patient.objects.create(user=p1u, mrn='MRN0001', first_name='Jane', last_name='Doe',
                date_of_birth=date(1990,5,12), gender='F', phone='555-0100',
                blood_group='O+', emergency_contact='John Doe 555-0101')
        if not Patient.objects.filter(mrn='MRN0002').exists():
            Patient.objects.create(mrn='MRN0002', first_name='Carlos', last_name='Mendez',
                date_of_birth=date(1985,3,2), gender='M', phone='555-0200', blood_group='A+')

        for name, price in [('Paracetamol 500mg',0.50),('Amoxicillin 250mg',1.20),('Ibuprofen 400mg',0.80)]:
            Medication.objects.get_or_create(name=name, defaults={'unit_price':price,'stock':100})
        for name, price in [('Complete Blood Count',15),('Urinalysis',10),('Blood Glucose',8)]:
            LabTest.objects.get_or_create(name=name, defaults={'price':price})

        w,_ = Ward.objects.get_or_create(name='General Ward A', defaults={'daily_rate':50})
        for n in ['101','102','103','104']:
            Bed.objects.get_or_create(ward=w, number=n)
        InsuranceProvider.objects.get_or_create(name='HealthPlus', defaults={'coverage_percent':70})

        # one appointment tomorrow
        p1 = Patient.objects.get(mrn='MRN0001')
        Appointment.objects.get_or_create(patient=p1, doctor=d1,
            scheduled_for=timezone.now()+timedelta(days=1),
            defaults={'reason':'Routine checkup'})
        self.stdout.write(self.style.SUCCESS('Seeded. Login as admin/doctor1/nurse1/patient1 with password123'))
