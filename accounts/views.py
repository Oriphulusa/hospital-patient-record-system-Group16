from django.contrib.auth.decorators import login_required, user_passes_test
from django.shortcuts import render, redirect, get_object_or_404
from .forms import StaffCreateForm
from .models import User

def admin_required(view):
    return user_passes_test(lambda u: u.is_authenticated and u.is_admin())(view)

@login_required
@admin_required
def user_list(request):
    users = User.objects.all().order_by('role','username')
    return render(request, 'accounts/user_list.html', {'users': users})

@login_required
@admin_required
def user_create(request):
    if request.method == 'POST':
        form = StaffCreateForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('accounts:user_list')
    else:
        form = StaffCreateForm()
    return render(request, 'accounts/user_form.html', {'form': form})
