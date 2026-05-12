from django import forms
from .models import Patient
class PatientForm(forms.ModelForm):
    class Meta:
        model = Patient
        exclude = ('user','created_at')
        widgets = {'date_of_birth': forms.DateInput(attrs={'type':'date'}),
                   'address': forms.Textarea(attrs={'rows':2}),
                   'allergies': forms.Textarea(attrs={'rows':2})}
