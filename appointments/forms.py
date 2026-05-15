from django import forms
from .models import Appointment
from accounts.models import User

class AppointmentsForm(forms.ModelForm):
 class AppointmentForm(forms.ModelForm):
    class Meta:
        model = Appointment
        fields = ['patient','doctor','scheduled_for','reason','status','notes']
        widgets = {'scheduled_for': forms.DateTimeInput(attrs={'type':'datetime-local'}),
                   'notes': forms.Textarea(attrs={'rows':2})}
    def __init__(self,*a,**k):
        super().__init__(*a,**k)
        self.fields['doctor'].queryset = User.objects.filter(role='doctor')   

