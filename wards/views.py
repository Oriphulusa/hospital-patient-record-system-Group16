from django.shortcuts import render
from common.decorators import login_required_raw, role_required
from common.sql import rows

@login_required_raw
@role_required('Admin','Receptionist','Doctor','Nurse')
def ward_list(request):
    wards=rows('''
        SELECT w."WardID", w."WardName", w."WardType", w."BedCapacity", w."Floor", w."Location",
               COUNT(a."AdmissionID") FILTER (WHERE a."ActualDischargeDate" IS NULL) AS occupied,
               (w."BedCapacity" - COUNT(a."AdmissionID") FILTER (WHERE a."ActualDischargeDate" IS NULL)) AS available
        FROM "Ward" w LEFT JOIN "Admission" a ON w."WardID"=a."WardID"
        GROUP BY w."WardID", w."WardName", w."WardType", w."BedCapacity", w."Floor", w."Location"
        ORDER BY w."WardName";
    ''')
    nurses=rows('''
        SELECT nw."WardID", w."WardName", CONCAT(s."FirstName", ' ', s."LastName") AS nurse, nw."ShiftType", nw."AssignmentDate"
        FROM "Nurse_Ward" nw JOIN "Ward" w ON nw."WardID"=w."WardID" JOIN "Staff" s ON nw."UserID"=s."UserID"
        ORDER BY w."WardName", nurse;
    ''')
    admissions=rows('''
        SELECT a."AdmissionID", a."AdmissionDate", a."ExpectedDischargeDate", a."ActualDischargeDate", a."AdmissionType", a."BedNumber",
               CONCAT(p."FirstName", ' ', p."LastName") AS patient, w."WardName"
        FROM "Admission" a JOIN "Patient" p ON a."PatientID"=p."PatientID" JOIN "Ward" w ON a."WardID"=w."WardID"
        ORDER BY a."AdmissionDate" DESC;
    ''')
    return render(request,'wards/list.html',{'wards':wards,'nurses':nurses,'admissions':admissions})
