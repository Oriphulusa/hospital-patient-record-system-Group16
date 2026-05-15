from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from .models import Appointment
from .forms import AppointmentForm


def appointment_list(request):
    u=request.user; qs=Appointment.objects.select_related('patient','doctor')
    if u.is_doctor(): qs=qs.filter(doctor=u)
    elif u.is_patient(): qs=qs.filter(patient__user=u)
    return render(request,'appointments/list.html',{'appointments':qs})


def appointment_create(request):
    if not (request.user.is_admin() or request.user.is_doctor()):
        return redirect('appointments:list')
    form = AppointmentForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('appointments:list')
    return render(request,'appointments/form.html',{'form':form,'title':'New Appointment'})
from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from .models import Appointment
from .forms import AppointmentForm

@login_required
def appointment_list(request):
    u=request.user; qs=Appointment.objects.select_related('patient','doctor')
    if u.is_doctor(): qs=qs.filter(doctor=u)
    elif u.is_patient(): qs=qs.filter(patient__user=u)
    return render(request,'appointments/list.html',{'appointments':qs})

@login_required
def appointment_create(request):
    if not (request.user.is_admin() or request.user.is_doctor()):
        return redirect('appointments:list')
    form = AppointmentForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('appointments:list')
    return render(request,'appointments/form.html',{'form':form,'title':'New Appointment'})

@login_required
def appointment_edit(request, pk):
    a = get_object_or_404(Appointment, pk=pk)
    if not (request.user.is_admin() or request.user==a.doctor):
        return redirect('appointments:list')
    form = AppointmentForm(request.POST or None, instance=a)
    if form.is_valid(): form.save(); return redirect('appointments:list')
    return render(request,'appointments/form.html',{'form':form,'title':'Edit Appointment'})
def appointment_edit(request, pk):
    a = get_object_or_404(Appointment, pk=pk)
    if not (request.user.is_admin() or request.user==a.doctor):
        return redirect('appointments:list')
    form = AppointmentForm(request.POST or None, instance=a)
    if form.is_valid(): form.save(); return redirect('appointments:list')
    return render(request,'appointments/form.html',{'form':form,'title':'Edit Appointment'})