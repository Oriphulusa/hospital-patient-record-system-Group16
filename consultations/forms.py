from django import forms
from .models import Consultation, Vitals

class ConsultationForm(forms.ModelForm):
    class Meta:
        model = Consultation
        fields = ['patient', 'chief_complaint', 'diagnosis', 'treatment_plan', 'notes']
        widgets = {
            'diagnosis': forms.Textarea(attrs={'rows': 3}),
            'treatment_plan': forms.Textarea(attrs={'rows': 3}),
            'notes': forms.Textarea(attrs={'rows': 2})
        }

class VitalsForm(forms.ModelForm):
    class Meta:
        model = Vitals
        exclude = ('recorded_by', 'recorded_at')
        widgets = {'notes': forms.Textarea(attrs={'rows': 2})}