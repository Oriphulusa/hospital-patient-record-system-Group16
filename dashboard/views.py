from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from django.utils import timezone
from datetime import timedelta
from patients.models import Patient
from appointments.models import Appointment
from consultations.models import Consultation
from wards.models import Bed, Admission
from billing.models import Bill
from pharmacy.models import Medication

@login_required
def home(request):
    u=request.user
    ctx={'today':timezone.now().date()}
    if u.is_admin():
        ctx.update({
            'patients_count': Patient.objects.count(),
            'appts_today': Appointment.objects.filter(scheduled_for__date=ctx['today']).count(),
            'beds_total': Bed.objects.count(),
            'beds_occupied': Bed.objects.filter(is_occupied=True).count(),
            'unpaid_bills': Bill.objects.exclude(status='paid').count(),
            'low_stock': Medication.objects.filter(stock__lt=10).count(),
        })
        return render(request,'dashboard/admin.html',ctx)
    if u.is_doctor():
        ctx.update({
            'my_appts': Appointment.objects.filter(doctor=u, scheduled_for__date__gte=ctx['today']).order_by('scheduled_for')[:10],
            'recent_consults': Consultation.objects.filter(doctor=u).order_by('-created_at')[:5],
            'my_admissions': Admission.objects.filter(doctor=u, discharged_at__isnull=True),
        })
        return render(request,'dashboard/doctor.html',ctx)
    if u.is_nurse():
        ctx.update({
            'admissions': Admission.objects.filter(discharged_at__isnull=True).select_related('patient','bed'),
            'patients': Patient.objects.order_by('-created_at')[:10],
        })
        return render(request,'dashboard/nurse.html',ctx)
    # patient
    p = getattr(u,'patient_profile', None)
    if p:
        ctx.update({'p':p,
            'appts': Appointment.objects.filter(patient=p).order_by('-scheduled_for')[:5],
            'consults': Consultation.objects.filter(patient=p).order_by('-created_at')[:5],
            'bills': Bill.objects.filter(patient=p).order_by('-created_at')[:5]})
    return render(request,'dashboard/patient.html',ctx)
