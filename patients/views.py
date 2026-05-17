from django.shortcuts import render, redirect
from common.decorators import login_required_raw, role_required
from common.sql import rows, one, execute

PATIENTS_SQL='''
SELECT p."PatientID", p."FirstName", p."LastName", p."Gender", p."DateOfBirth", p."Phone", p."Email", p."City", p."Province", p."BloodType", w."WardName"
FROM "Patient" p LEFT JOIN "Ward" w ON p."WardID"=w."WardID"
ORDER BY p."PatientID";
'''

@login_required_raw
@role_required('Admin','Receptionist','Doctor','Nurse','BillingOfficer','LabTechnician')
def patient_list(request):
    q=(request.GET.get('q') or '').strip()
    if q:
        data=rows('''
            SELECT p."PatientID", p."FirstName", p."LastName", p."Gender", p."DateOfBirth", p."Phone", p."Email", p."City", p."Province", p."BloodType", w."WardName"
            FROM "Patient" p LEFT JOIN "Ward" w ON p."WardID"=w."WardID"
            WHERE lower(p."FirstName" || ' ' || p."LastName") LIKE lower(%s) OR lower(p."City") LIKE lower(%s) OR lower(COALESCE(p."Email",'')) LIKE lower(%s)
            ORDER BY p."PatientID";
        ''',[f'%{q}%',f'%{q}%',f'%{q}%'])
    else:
        data=rows(PATIENTS_SQL)
    return render(request,'patients/list.html',{'patients':data,'q':q})

@login_required_raw
@role_required('Admin','Receptionist','Doctor','Nurse','BillingOfficer','LabTechnician')
def patient_detail(request, patient_id):
    patient=one('''SELECT p.*, w."WardName" FROM "Patient" p LEFT JOIN "Ward" w ON p."WardID"=w."WardID" WHERE p."PatientID"=%s''',[patient_id])
    allergies=rows('SELECT * FROM "Allergy" WHERE "PatientID"=%s ORDER BY "DateRecorded" DESC',[patient_id])
    appointments=rows('''SELECT ap.*, CONCAT(s."FirstName", ' ', s."LastName") AS doctor FROM "Appointment" ap JOIN "Staff" s ON ap."DoctorID"=s."UserID" WHERE ap."PatientID"=%s ORDER BY ap."AppointmentDate" DESC''',[patient_id])
    bills=rows('SELECT * FROM "Billing" WHERE "PatientID"=%s ORDER BY "BillDate" DESC',[patient_id])
    return render(request,'patients/detail.html',{'patient':patient,'allergies':allergies,'appointments':appointments,'bills':bills})

@login_required_raw
@role_required('Admin','Receptionist')
def patient_new(request):
    wards=rows('SELECT "WardID", "WardName" FROM "Ward" ORDER BY "WardName"')
    error=None
    if request.method=='POST':
        try:
            execute('''
                INSERT INTO "Patient" ("FirstName","LastName","DateOfBirth","Gender","Phone","Email","Street","City","Province","PostalCode","IDNumber","PassportNumber","BloodType","EmergencyContactName","EmergencyContactPhone","WardID")
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NULL,%s,%s,%s,%s,NULLIF(%s,'')::integer)
            ''',[
                request.POST.get('first_name'), request.POST.get('last_name'), request.POST.get('dob'), request.POST.get('gender'), request.POST.get('phone') or None, request.POST.get('email') or None,
                request.POST.get('street') or 'Demo Street', request.POST.get('city') or 'Mahikeng', request.POST.get('province') or 'North West', request.POST.get('postal_code') or '2745',
                request.POST.get('passport') or ('PASS' + request.POST.get('phone','000000000')[-6:]), request.POST.get('blood_type') or None, request.POST.get('emergency_name') or None, request.POST.get('emergency_phone') or None, request.POST.get('ward_id') or ''
            ])
            return redirect('patient_list')
        except Exception:
            error='The patient could not be saved. Please check the entered details and try again.'
    return render(request,'patients/form.html',{'wards':wards,'error':error})
