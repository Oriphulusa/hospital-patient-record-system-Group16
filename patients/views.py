from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.db.models import Q
from .models import Patient
from .forms import PatientForm

def patient_list(request):
    u = request.user
    qs = Patient.objects.all()
    if u.is_patient():
        qs = qs.filter(user=u)
    q = request.GET.get('q','').strip()
    if q:
        qs = qs.filter(Q(first_name__icontains=q)|Q(last_name__icontains=q)|Q(mrn__icontains=q))
    return render(request, 'patients/list.html', {'patients': qs.order_by('-created_at'), 'q': q})

def patient_detail(request, pk):
    p = get_object_or_404(Patient, pk=pk)
    u = request.user
    if u.is_patient() and p.user_id != u.id:
        return redirect('patients:list')
    return render(request, 'patients/detail.html', {'p': p,
        'consultations': p.consultations.all().order_by('-created_at'),
        'appointments': p.appointments.all().order_by('-scheduled_for'),
        'admissions': p.admissions.all().order_by('-admitted_at'),
        'bills': p.bills.all().order_by('-created_at'),
    })

def patient_create(request):
    if not (request.user.is_admin() or request.user.is_nurse()):
        return redirect('patients:list')
    if request.method == 'POST':
        form = PatientForm(request.POST)
        if form.is_valid():
            form.save(); return redirect('patients:list')
    else:
        form = PatientForm()
    return render(request, 'patients/form.html', {'form': form, 'title':'New Patient'})

def patient_edit(request, pk):
    if not request.user.is_admin():
        return redirect('patients:list')
    p = get_object_or_404(Patient, pk=pk)
    form = PatientForm(request.POST or None, instance=p)
    if form.is_valid():
        form.save(); return redirect('patients:detail', pk=pk)
    return render(request, 'patients/form.html', {'form': form, 'title':'Edit Patient'})
