from django.db import connection


def rows(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])
        columns=[c[0] for c in cur.description] if cur.description else []
        return [dict(zip(columns,row)) for row in cur.fetchall()] if columns else []


def one(sql, params=None):
    result=rows(sql, params)
    return result[0] if result else None


def execute(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])


def table_counts():
    return rows('''
        SELECT 'Staff members' AS table_name, COUNT(*) AS total FROM "Staff" UNION ALL
        SELECT 'Departments', COUNT(*) FROM "Department" UNION ALL
        SELECT 'Doctors', COUNT(*) FROM "Doctor" UNION ALL
        SELECT 'Nurses', COUNT(*) FROM "Nurse" UNION ALL
        SELECT 'Patients', COUNT(*) FROM "Patient" UNION ALL
        SELECT 'Appointments', COUNT(*) FROM "Appointment" UNION ALL
        SELECT 'Admissions', COUNT(*) FROM "Admission" UNION ALL
        SELECT 'Diagnoses', COUNT(*) FROM "Diagnosis" UNION ALL
        SELECT 'Prescriptions', COUNT(*) FROM "Prescription" UNION ALL
        SELECT 'Medication items', COUNT(*) FROM "Medication" UNION ALL
        SELECT 'Laboratory tests', COUNT(*) FROM "Laboratory_Test" UNION ALL
        SELECT 'Billing records', COUNT(*) FROM "Billing";
    ''')


def dashboard_stats():
    return one('''
        SELECT
          (SELECT COUNT(*) FROM "Patient") AS patients,
          (SELECT COUNT(*) FROM "Doctor") AS doctors,
          (SELECT COUNT(*) FROM "Nurse") AS nurses,
          (SELECT COUNT(*) FROM "Appointment") AS appointments,
          (SELECT COUNT(*) FROM "Appointment" WHERE "AppointmentDate"=CURRENT_DATE) AS today_appointments,
          (SELECT COUNT(*) FROM "Admission" WHERE "ActualDischargeDate" IS NULL) AS active_admissions,
          COALESCE((SELECT SUM("OutstandingBalance") FROM "Billing"),0) AS outstanding;
    ''')
