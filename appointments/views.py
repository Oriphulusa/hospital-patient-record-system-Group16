from django.shortcuts import render, redirect
from django.core.mail import send_mail
from django.conf import settings
from common.decorators import login_required_raw, role_required
from common.sql import rows, one, execute

APPOINTMENTS_SQL='''
SELECT ap."AppointmentID", ap."AppointmentDate", ap."AppointmentTime", ap."Status", ap."Reason",
       p."PatientID", CONCAT(p."FirstName", ' ', p."LastName") AS patient, p."Email" AS patient_email,
       d."UserID" AS doctor_id, CONCAT(s."FirstName", ' ', s."LastName") AS doctor, s."Email" AS doctor_email,
       doc."Specialization"
FROM "Appointment" ap
JOIN "Patient" p ON ap."PatientID"=p."PatientID"
JOIN "Doctor" doc ON ap."DoctorID"=doc."UserID"
JOIN "Staff" s ON doc."UserID"=s."UserID"
JOIN "Doctor" d ON d."UserID"=doc."UserID"
'''
ORDER_CLAUSE='ORDER BY ap."AppointmentDate" DESC, ap."AppointmentTime" ASC;'

@login_required_raw
@role_required('Admin','Receptionist','Doctor','Nurse')
def appointment_list(request):
    status=request.GET.get('status') or ''
    staff=request.session.get('staff') or {}
    params=[]
    filters=[]
    if status:
        filters.append('ap."Status"=%s')
        params.append(status)
    if staff.get('Role') == 'Doctor':
        filters.append('ap."DoctorID"=%s')
        params.append(staff.get('UserID'))
    sql=APPOINTMENTS_SQL
    if filters:
        sql += ' WHERE ' + ' AND '.join(filters) + ' '
    sql += ORDER_CLAUSE
    data=rows(sql, params)
    return render(request,'appointments/list.html',{'appointments':data,'status':status})

@login_required_raw
@role_required('Admin','Receptionist')
def appointment_new(request):
    patients=rows('SELECT "PatientID", "FirstName", "LastName", "Email" FROM "Patient" ORDER BY "LastName"')
    doctors=rows('''SELECT d."UserID", CONCAT(s."FirstName", ' ', s."LastName") AS name, s."Email", d."Specialization" FROM "Doctor" d JOIN "Staff" s ON d."UserID"=s."UserID" ORDER BY name''')
    receptionists=rows('''SELECT r."UserID", CONCAT(s."FirstName", ' ', s."LastName") AS name FROM "Receptionist" r JOIN "Staff" s ON r."UserID"=s."UserID" ORDER BY name''')
    error=None
    if request.method=='POST':
        try:
            patient_id=request.POST.get('patient_id')
            doctor_id=request.POST.get('doctor_id')
            appt_date=request.POST.get('appointment_date')
            appt_time=request.POST.get('appointment_time')
            reason=request.POST.get('reason') or 'General check-up'
            receptionist_id=request.POST.get('receptionist_id') or None
            execute('''INSERT INTO "Appointment" ("AppointmentDate","AppointmentTime","Status","Reason","PatientID","DoctorID","ReceptionistID") VALUES (%s,%s,'Scheduled',%s,%s,%s,%s)''',[appt_date, appt_time, reason, patient_id, doctor_id, receptionist_id])
            patient=one('SELECT "FirstName", "LastName", "Email" FROM "Patient" WHERE "PatientID"=%s',[patient_id])
            doctor=one('''SELECT s."FirstName", s."LastName", s."Email" FROM "Staff" s JOIN "Doctor" d ON s."UserID"=d."UserID" WHERE d."UserID"=%s''',[doctor_id])
            recipients=[x for x in [patient.get('Email') if patient else None, doctor.get('Email') if doctor else None] if x]
            subject='MediCare HMS Appointment Notification'
            body=f'''Appointment Scheduled\n\nPatient: {patient['FirstName']} {patient['LastName']}\nDoctor: Dr {doctor['FirstName']} {doctor['LastName']}\nDate: {appt_date}\nTime: {appt_time}\nReason: {reason}\n\nThis message was sent by MediCare HMS.'''
            if recipients:
                send_mail(subject, body, settings.DEFAULT_FROM_EMAIL, recipients, fail_silently=True)
            return redirect('appointment_list')
        except Exception as e:
            message = str(e)
            if 'uq_doctor_appointment_slot' in message or 'duplicate key value' in message:
                error = 'This doctor is already booked for the selected date and time. Please choose another available slot.'
            else:
                error = 'The appointment could not be created. Please check the details and try again.'
    return render(request,'appointments/form.html',{'patients':patients,'doctors':doctors,'receptionists':receptionists,'error':error})

@login_required_raw
@role_required('Admin','Receptionist','Doctor')
def appointment_status(request, appointment_id):
    status=request.POST.get('status')
    staff=request.session.get('staff') or {}
    if status in ['Scheduled','Completed','Cancelled','No-Show']:
        if staff.get('Role') == 'Doctor':
            execute('UPDATE "Appointment" SET "Status"=%s WHERE "AppointmentID"=%s AND "DoctorID"=%s',[status, appointment_id, staff.get('UserID')])
        else:
            execute('UPDATE "Appointment" SET "Status"=%s WHERE "AppointmentID"=%s',[status, appointment_id])
    return redirect('appointment_list')
