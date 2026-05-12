from django import forms
from .models import InsuranceProvider, PatientInsurance
class ProviderForm(forms.ModelForm):
    class Meta: model=InsuranceProvider; fields='__all__'
class PatientInsuranceForm(forms.ModelForm):
    class Meta:
        model=PatientInsurance; fields='__all__'
        widgets={'valid_until':forms.DateInput(attrs={'type':'date'})}
