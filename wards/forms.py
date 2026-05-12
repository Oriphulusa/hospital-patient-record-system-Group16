from django import forms
from .models import Ward, Bed, Admission
from accounts.models import User
class WardForm(forms.ModelForm):
    class Meta: model=Ward; fields='__all__'
class BedForm(forms.ModelForm):
    class Meta: model=Bed; fields=['ward','number']
class AdmissionForm(forms.ModelForm):
    class Meta:
        model=Admission
        fields=['patient','bed','doctor','reason','notes']
        widgets={'notes':forms.Textarea(attrs={'rows':2})}
    def __init__(self,*a,**k):
        super().__init__(*a,**k)
        self.fields['bed'].queryset = Bed.objects.filter(is_occupied=False)
        self.fields['doctor'].queryset = User.objects.filter(role='doctor')
