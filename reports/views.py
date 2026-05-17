from django.shortcuts import render
from django.http import JsonResponse
from common.decorators import login_required_raw, role_required
from common.sql import rows, dashboard_stats, table_counts

QUERY_DEMOS={
 'Company information requirements': '''
SELECT p."PatientID", p."FirstName", p."LastName", ap."AppointmentDate", ap."AppointmentTime", ap."Status",
       CONCAT(s."FirstName", ' ', s."LastName") AS "Doctor"
FROM "Patient" p
JOIN "Appointment" ap ON p."PatientID" = ap."PatientID"
JOIN "Staff" s ON ap."DoctorID" = s."UserID"
ORDER BY ap."AppointmentDate" DESC;''',
}

@login_required_raw
def dashboard(request):
    staff=request.session.get('staff') or {}
    params=[]
    doctor_filter=''
    if staff.get('Role') == 'Doctor':
        doctor_filter='WHERE ap."DoctorID"=%s'
        params.append(staff.get('UserID'))
    upcoming=rows(f'''
        SELECT ap."AppointmentID", ap."AppointmentDate", ap."AppointmentTime", ap."Status", ap."Reason",
               CONCAT(p."FirstName", ' ', p."LastName") AS patient,
               CONCAT(s."FirstName", ' ', s."LastName") AS doctor
        FROM "Appointment" ap
        JOIN "Patient" p ON ap."PatientID"=p."PatientID"
        JOIN "Staff" s ON ap."DoctorID"=s."UserID"
        {doctor_filter}
        ORDER BY ap."AppointmentDate" DESC, ap."AppointmentTime" ASC LIMIT 8;
    ''', params)
    return render(request,'reports/dashboard.html',{'stats':dashboard_stats(), 'upcoming':upcoming, 'counts':table_counts()})

@login_required_raw
@role_required('Admin')
def sql_demo(request):
    selected='Company information requirements'
    sql=QUERY_DEMOS[selected]
    return render(request,'reports/sql_demo.html',{'queries':list(QUERY_DEMOS.keys()),'selected':selected,'sql':sql,'results':rows(sql)})

@login_required_raw
@role_required('Admin')
def database_proof(request):
    raw_views=rows("""
        SELECT table_name FROM information_schema.views
        WHERE table_schema='public'
        ORDER BY table_name;
    """)
    labels=[]
    for v in raw_views:
        label=(v.get('table_name') or '').replace('vw_','').replace('_',' ')
        labels.append({'label':label.title()})
    return render(request,'reports/database_proof.html',{'counts':table_counts(),'views':labels})

@login_required_raw
@role_required('Admin')
def api_dashboard(request):
    return JsonResponse({'stats':dashboard_stats(),'counts':table_counts()})

@login_required_raw
@role_required('Admin')
def api_patients(request):
    data=rows('SELECT * FROM "Patient" ORDER BY "PatientID"')
    return JsonResponse({'patients':data}, safe=False)

@login_required_raw
@role_required('Admin')
def api_appointments(request):
    data=rows('SELECT * FROM "Appointment" ORDER BY "AppointmentDate" DESC, "AppointmentTime" ASC')
    return JsonResponse({'appointments':data}, safe=False)
