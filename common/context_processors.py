def current_staff(request):
    return {'current_staff': request.session.get('staff')}
