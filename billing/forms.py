from django import forms
from .models import Bill, BillItem, Payment
class BillForm(forms.ModelForm):
    class Meta: model=Bill; fields=['patient','insurance','description']
class BillItemForm(forms.ModelForm):
    class Meta: model=BillItem; fields=['description','quantity','unit_price']
class PaymentForm(forms.ModelForm):
    class Meta: model=Payment; fields=['amount','method','reference']
