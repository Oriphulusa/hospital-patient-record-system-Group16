from django.shortcuts import render, redirect
from common.decorators import login_required_raw, role_required
from common.sql import rows, execute

@login_required_raw
@role_required('Admin','Doctor','Nurse','LabTechnician')
def clinical_home(request):
    staff=request.session.get('staff') or {}
    params=[]
    doctor_filter=''
    if staff.get('Role') == 'Doctor':
        doctor_filter='WHERE dg."DoctorID"=%s'
        params.append(staff.get('UserID'))
    diagnoses=rows(f'''
        SELECT dg."DiagnosisID", dg."ICD10Code", dg."Description", dg."Severity", dg."DiagnosisDate",
               CONCAT(p."FirstName", ' ', p."LastName") AS patient,
               CONCAT(s."FirstName", ' ', s."LastName") AS doctor
        FROM "Diagnosis" dg
        JOIN "Admission" a ON dg."AdmissionID"=a."AdmissionID"
        JOIN "Patient" p ON a."PatientID"=p."PatientID"
        JOIN "Staff" s ON dg."DoctorID"=s."UserID"
        {doctor_filter}
        ORDER BY dg."DiagnosisDate" DESC;
    ''', params)
    prescriptions=rows('''
        SELECT pr."PrescriptionID", pr."DateIssued", pr."DosageInstructions", dg."Description" AS diagnosis,
               CONCAT(s."FirstName", ' ', s."LastName") AS doctor
        FROM "Prescription" pr
        JOIN "Diagnosis" dg ON pr."DiagnosisID"=dg."DiagnosisID"
        JOIN "Staff" s ON pr."DoctorID"=s."UserID"
        ORDER BY pr."DateIssued" DESC;
    ''')
    labs=rows('''
        SELECT lt."TestID", lt."TestCode", lt."TestDescription", lt."OrderDate", lt."Status", lt."ResultValue", lt."ResultUnit", lt."ReferenceRange", lt."ResultDate",
               CONCAT(p."FirstName", ' ', p."LastName") AS patient
        FROM "Laboratory_Test" lt
        JOIN "Admission" a ON lt."AdmissionID"=a."AdmissionID"
        JOIN "Patient" p ON a."PatientID"=p."PatientID"
        ORDER BY lt."OrderDate" DESC;
    ''')
    meds=rows('SELECT * FROM "Medication" ORDER BY "MedicationName"')
    return render(request,'clinical/home.html',{'diagnoses':diagnoses,'prescriptions':prescriptions,'labs':labs,'meds':meds})

@login_required_raw
@role_required('Admin','LabTechnician')
def lab_result(request, test_id):
    if request.method=='POST':
        execute('''UPDATE "Laboratory_Test" SET "ResultValue"=%s, "ResultUnit"=%s, "ReferenceRange"=%s, "ResultDate"=CURRENT_DATE, "Status"='Resulted' WHERE "TestID"=%s''',[request.POST.get('value'), request.POST.get('unit'), request.POST.get('range'), test_id])
    return redirect('clinical_home')
