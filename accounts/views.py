from django.shortcuts import render, redirect
from common.sql import rows
from common.decorators import login_required_raw, role_required

STAFF_LOGIN_SQL = '''
SELECT "UserID", "FirstName", "LastName", "Email", "Role"
FROM "Staff"
WHERE "IsActive"=TRUE AND (
    lower("Email") = lower(%s)
    OR lower("Role") = lower(%s)
    OR lower("FirstName") = lower(%s)
    OR lower("FirstName" || '.' || "LastName") = lower(%s)
    OR lower(replace("Email", '@hprs.co.za', '')) = lower(%s)
)
ORDER BY "UserID" LIMIT 1;
'''

def login_view(request):
    error=None
    if request.method=='POST':
        username=(request.POST.get('username') or '').strip()
        password=request.POST.get('password') or ''
        key=username.lower().replace(' ', '.')
        if password != 'password123':
            error='Invalid username or password. Demo password is password123.'
        else:
            result = rows(STAFF_LOGIN_SQL, [username, username, username, key, key])
            if result:
                request.session['staff']=result[0]
                return redirect('dashboard')
            error='No matching staff account was found. Please check the username or work email address.'
    return render(request,'accounts/login.html',{'error':error})

def logout_view(request):
    request.session.flush()
    return redirect('landing')

@login_required_raw
@role_required('Admin')
def staff_list(request):
    staff=rows('''
        SELECT "UserID", "FirstName", "LastName", "Phone", "Email", "Role", "IsActive", "DateJoined"
        FROM "Staff" ORDER BY "Role", "LastName";
    ''')
    return render(request,'accounts/staff_list.html',{'staff':staff})
