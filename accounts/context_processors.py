def role_context(request):
    u = getattr(request, 'user', None)
    if not u or not u.is_authenticated:
        return {}
    return {'is_admin': u.is_admin(), 'is_doctor': u.is_doctor(),
            'is_nurse': u.is_nurse(), 'is_patient': u.is_patient()}
