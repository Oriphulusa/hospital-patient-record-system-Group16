from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from django.utils import timezone
from .models import LabTest, LabOrder
from .forms import LabTestForm, LabOrderForm, LabResultForm
from consultations.models import Consultation

@login_required
def test_list(request):
    return render(request,'laboratory/test_list.html',{'tests':LabTest.objects.all()})

@login_required
def test_create(request):
    if not request.user.is_admin(): return redirect('laboratory:test_list')
    form=LabTestForm(request.POST or None)
    if form.is_valid(): form.save(); return redirect('laboratory:test_list')
    return render(request,'laboratory/test_form.html',{'form':form})

@login_required
def order_create(request, consultation_id):
    if not request.user.is_doctor(): return redirect('consultations:list')
    c=get_object_or_404(Consultation, pk=consultation_id)
    form=LabOrderForm(request.POST or None)
    if form.is_valid():
        o=form.save(commit=False); o.consultation=c; o.save()
        return redirect('consultations:detail', pk=c.pk)
    return render(request,'laboratory/order_form.html',{'form':form,'c':c})

@login_required
def order_complete(request, pk):
    if not (request.user.is_doctor() or request.user.is_admin()):
        return redirect('consultations:list')
    o=get_object_or_404(LabOrder, pk=pk)
    form=LabResultForm(request.POST or None, instance=o)
    if form.is_valid():
        o=form.save(commit=False); o.status='completed'; o.completed_at=timezone.now(); o.save()
        return redirect('consultations:detail', pk=o.consultation_id)
    return render(request,'laboratory/result_form.html',{'form':form,'o':o})
