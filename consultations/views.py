from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from .models import Consultation, Vitals
from .forms import ConsultationForm, VitalsForm
from patients.models import Patient

def consult_list(request):
    u = request.user
    qs = Consultation.objects.select_related('patient', 'doctor')
    if u.is_doctor():
        qs = qs.filter(doctor=u)
    elif u.is_patient():
        qs = qs.filter(patient__user=u)
    return render(request, 'consultations/list.html', {'items': qs})

def consult_create(request):
    if not request.user.is_doctor():
        return redirect('consultations:list')
    form = ConsultationForm(request.POST or None)
    if form.is_valid():
        c = form.save(commit=False)
        c.doctor = request.user
        c.save()
        return redirect('consultations:detail', pk=c.pk)
    return render(request, 'consultations/form.html', {'form': form, 'title': 'New Consultation'})

def consult_detail(request, pk):
    c = get_object_or_404(Consultation, pk=pk)
    return render(request, 'consultations/detail.html', {
        'c': c,
        'prescriptions': c.prescriptions.all(),
        'lab_orders': c.lab_orders.all()
    })

def vitals_create(request, patient_id):
    p = get_object_or_404(Patient, pk=patient_id)
    if not (request.user.is_nurse() or request.user.is_doctor() or request.user.is_admin()):
        return redirect('patients:detail', pk=patient_id)
    form = VitalsForm(request.POST or None)
    if form.is_valid():
        v = form.save(commit=False)
        v.patient = p
        v.recorded_by = request.user
        v.save()
        return redirect('patients:detail', pk=patient_id)
    return render(request, 'consultations/vitals_form.html', {'form': form, 'p': p})