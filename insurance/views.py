from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from .models import InsuranceProvider, PatientInsurance
from .forms import ProviderForm, PatientInsuranceForm

@login_required
def provider_list(request):
    return render(request,'insurance/provider_list.html',{
        'providers':InsuranceProvider.objects.all(),
        'policies':PatientInsurance.objects.select_related('patient','provider').all()})

@login_required
def provider_create(request):
    if not request.user.is_admin(): return redirect('insurance:provider_list')
    form=ProviderForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('insurance:provider_list')
    return render(request,'insurance/form.html',{'form':form,'title':'New Provider'})

@login_required
def policy_create(request):
    if not request.user.is_admin(): return redirect('insurance:provider_list')
    form=PatientInsuranceForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('insurance:provider_list')
    return render(request,'insurance/form.html',{'form':form,'title':'Assign Insurance'})
