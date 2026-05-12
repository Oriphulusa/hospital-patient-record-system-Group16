from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect, get_object_or_404
from .models import Bill, BillItem, Payment
from .forms import BillForm, BillItemForm, PaymentForm

@login_required
def bill_list(request):
    u=request.user; qs=Bill.objects.select_related('patient','insurance')
    if u.is_patient(): qs=qs.filter(patient__user=u)
    return render(request,'billing/list.html',{'bills':qs})

@login_required
def bill_create(request):
    if not request.user.is_admin(): return redirect('billing:list')
    form=BillForm(request.POST or None)
    if form.is_valid():
        b=form.save(); return redirect('billing:detail', pk=b.pk)
    return render(request,'billing/form.html',{'form':form,'title':'New Bill'})

@login_required
def bill_detail(request, pk):
    b=get_object_or_404(Bill, pk=pk)
    u=request.user
    if u.is_patient() and b.patient.user_id != u.id: return redirect('billing:list')
    return render(request,'billing/detail.html',{'b':b,
        'item_form':BillItemForm(), 'pay_form':PaymentForm()})

@login_required
def add_item(request, pk):
    if not request.user.is_admin(): return redirect('billing:detail', pk=pk)
    b=get_object_or_404(Bill, pk=pk)
    form=BillItemForm(request.POST or None)
    if form.is_valid():
        i=form.save(commit=False); i.bill=b; i.save(); b.refresh_status()
    return redirect('billing:detail', pk=pk)

@login_required
def add_payment(request, pk):
    if not request.user.is_admin(): return redirect('billing:detail', pk=pk)
    b=get_object_or_404(Bill, pk=pk)
    form=PaymentForm(request.POST or None)
    if form.is_valid():
        p=form.save(commit=False); p.bill=b; p.save(); b.refresh_status()
    return redirect('billing:detail', pk=pk)
