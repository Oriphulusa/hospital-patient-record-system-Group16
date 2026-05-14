from django import forms
from .models import Medication, Prescription
class MedicationForm(forms.ModelForm):
    class Meta: model=Medication; fields='__all__'
class PrescriptionForm(forms.ModelForm):
    class Meta: model=Prescription; fields=['medication','dosage','frequency','quantity']
