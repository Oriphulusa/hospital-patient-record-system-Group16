from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.utils import timezone
from .models import Ward, Bed, Admission
from .forms import WardForm, BedForm, AdmissionForm

@login_required
def ward_list(request):
    return render(request,'wards/list.html',{'wards':Ward.objects.prefetch_related('beds').all(),
        'admissions':Admission.objects.filter(discharged_at__isnull=True).select_related('patient','bed','bed__ward','doctor')})

@login_required
def ward_create(request):
    if not request.user.is_admin(): return redirect('wards:list')
    form=WardForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('wards:list')
    return render(request,'wards/form.html',{'form':form,'title':'New Ward'})

@login_required
def bed_create(request):
    if not request.user.is_admin(): return redirect('wards:list')
    form=BedForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('wards:list')
    return render(request,'wards/form.html',{'form':form,'title':'New Bed'})

@login_required
def admit(request):
    if not (request.user.is_admin() or request.user.is_doctor()): return redirect('wards:list')
    form=AdmissionForm(request.POST or None)
    if form.is_valid():
        a=form.save(); a.bed.is_occupied=True; a.bed.save()
        return redirect('wards:list')
    return render(request,'wards/form.html',{'form':form,'title':'Admit Patient'})

@login_required
def discharge(request, pk):
    if not (request.user.is_admin() or request.user.is_doctor()): return redirect('wards:list')
    a=get_object_or_404(Admission, pk=pk)
    if a.discharged_at is None:
        a.discharged_at=timezone.now(); a.save()
        a.bed.is_occupied=False; a.bed.save()
    return redirect('wards:list')
