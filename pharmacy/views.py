from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from .models import Medication, Prescription
from .forms import MedicationForm, PrescriptionForm
from consultations.models import Consultation

@login_required
def med_list(request):
    return render(request,'pharmacy/med_list.html',{'meds':Medication.objects.all()})

@login_required
def med_create(request):
    if not (request.user.is_admin() or request.user.is_doctor()):
        return redirect('pharmacy:med_list')
    form=MedicationForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('pharmacy:med_list')
    return render(request,'pharmacy/med_form.html',{'form':form})

@login_required
def prescribe(request, consultation_id):
    if not request.user.is_doctor(): return redirect('consultations:list')
    c = get_object_or_404(Consultation, pk=consultation_id)
    form=PrescriptionForm(request.POST or None)
    if form.is_valid():
        p=form.save(commit=False); p.consultation=c; p.save()
        return redirect('consultations:detail', pk=c.pk)
    return render(request,'pharmacy/prescribe_form.html',{'form':form,'c':c})

@login_required
def dispense(request, pk):
    if not request.user.is_doctor(): return redirect('consultations:list')
    p = get_object_or_404(Prescription, pk=pk)
    if not p.dispensed:
        if p.medication.stock >= p.quantity:
            p.medication.stock -= p.quantity; p.medication.save()
            p.dispensed = True; p.save()
            messages.success(request, 'Dispensed.')
        else:
            messages.error(request, 'Insufficient stock.')
    return redirect('consultations:detail', pk=p.consultation_id)
