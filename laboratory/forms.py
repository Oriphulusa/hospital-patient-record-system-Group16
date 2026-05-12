from django import forms
from .models import LabTest, LabOrder
class LabTestForm(forms.ModelForm):
    class Meta: model=LabTest; fields='__all__'
class LabOrderForm(forms.ModelForm):
    class Meta: model=LabOrder; fields=['test']
class LabResultForm(forms.ModelForm):
    class Meta: model=LabOrder; fields=['result']
        
