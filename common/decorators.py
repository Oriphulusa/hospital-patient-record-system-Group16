from functools import wraps
from django.shortcuts import redirect
from django.contrib import messages


def login_required_raw(view_func):
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not request.session.get('staff'):
            return redirect('login')
        return view_func(request, *args, **kwargs)
    return wrapper


def role_required(*allowed_roles):
    allowed = set(allowed_roles)
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):
            staff = request.session.get('staff')
            if not staff:
                return redirect('login')
            if staff.get('Role') not in allowed:
                messages.error(request, 'You do not have access to that section for your staff role.')
                return redirect('dashboard')
            return view_func(request, *args, **kwargs)
        return wrapper
    return decorator
