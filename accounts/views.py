from django.shortcuts import render, redirect
from django.db import connection, transaction, IntegrityError

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
    error = None

    if request.method == 'POST':
        username = (request.POST.get('username') or '').strip()
        password = request.POST.get('password') or ''
        key = username.lower().replace(' ', '.')

        if password != 'password123':
            error = 'Invalid username or password. Demo password is password123.'
        else:
            result = rows(STAFF_LOGIN_SQL, [username, username, username, key, key])

            if result:
                request.session['staff'] = result[0]
                return redirect('dashboard')

            error = 'No matching staff account was found. Please check the username or work email address.'

    return render(request, 'accounts/login.html', {'error': error})


def logout_view(request):
    request.session.flush()
    return redirect('landing')


@login_required_raw
@role_required('Admin', 'ITManager')
def staff_list(request):
    staff = rows('''
        SELECT "UserID", "FirstName", "LastName", "Phone", "Email", "Role", "IsActive", "DateJoined"
        FROM "Staff"
        ORDER BY "Role", "LastName";
    ''')

    return render(request, 'accounts/staff_list.html', {'staff': staff})


@login_required_raw
@role_required('Admin', 'ITManager')
def staff_create(request):
    current_staff = request.session.get("staff") or {}
    current_role = current_staff.get("Role")

    if current_role == "ITManager":
        allowed_roles = ["Admin", "Doctor", "Nurse", "Receptionist", "BillingOfficer", "LabTechnician", "ITManager"]
    else:
        allowed_roles = ["Doctor", "Nurse", "Receptionist", "BillingOfficer", "LabTechnician"]

    departments = rows('SELECT "DepartmentID", "DepartmentName" FROM "Department" ORDER BY "DepartmentName"')
    error = None

    if request.method == "POST":
        first_name = request.POST.get("first_name", "").strip()
        last_name = request.POST.get("last_name", "").strip()
        phone = request.POST.get("phone", "").strip() or None
        email = request.POST.get("email", "").strip()
        role = request.POST.get("role", "").strip()

        specialization = request.POST.get("specialization", "").strip()
        license_number = request.POST.get("license_number", "").strip()
        years_experience = request.POST.get("years_experience", "0").strip() or "0"
        department_id = request.POST.get("department_id", "").strip()

        registration_no = request.POST.get("registration_no", "").strip()
        nurse_grade = request.POST.get("nurse_grade", "").strip()

        desk_number = request.POST.get("desk_number", "").strip()
        desk_assignment = request.POST.get("desk_assignment", "").strip()

        employee_number = request.POST.get("employee_number", "").strip()
        laboratory_section = request.POST.get("laboratory_section", "").strip()

        if role not in allowed_roles:
            error = "You are not allowed to create this staff role."
        elif not first_name or not last_name or not email or not role:
            error = "First name, last name, email and role are required."
        else:
            try:
                with transaction.atomic():
                    with connection.cursor() as cursor:
                        cursor.execute(
                            '''
                            INSERT INTO "Staff"
                            ("FirstName", "LastName", "Phone", "Email", "Role", "IsActive")
                            VALUES (%s, %s, %s, %s, %s, TRUE)
                            RETURNING "UserID"
                            ''',
                            [first_name, last_name, phone, email, role]
                        )
                        new_user_id = cursor.fetchone()[0]

                        if role == "Doctor":
                            if not specialization or not license_number or not department_id:
                                raise ValueError("Doctor requires specialization, license number and department.")

                            cursor.execute(
                                '''
                                INSERT INTO "Doctor"
                                ("UserID", "Specialization", "LicenseNumber", "YearsExperience", "DepartmentID")
                                VALUES (%s, %s, %s, %s, %s)
                                ''',
                                [new_user_id, specialization, license_number, int(years_experience), int(department_id)]
                            )

                        elif role == "Nurse":
                            if not registration_no or not nurse_grade:
                                raise ValueError("Nurse requires registration number and nurse grade.")

                            cursor.execute(
                                '''
                                INSERT INTO "Nurse"
                                ("UserID", "RegistrationNo", "NurseGrade")
                                VALUES (%s, %s, %s)
                                ''',
                                [new_user_id, registration_no, nurse_grade]
                            )

                        elif role == "Receptionist":
                            cursor.execute(
                                '''
                                INSERT INTO "Receptionist"
                                ("UserID", "DeskNumber", "DeskAssignment")
                                VALUES (%s, %s, %s)
                                ''',
                                [new_user_id, desk_number or None, desk_assignment or None]
                            )

                        elif role == "LabTechnician":
                            if not employee_number or not laboratory_section:
                                raise ValueError("Lab Technician requires employee number and laboratory section.")

                            cursor.execute(
                                '''
                                INSERT INTO "LabTechnician"
                                ("UserID", "EmployeeNumber", "LaboratorySection")
                                VALUES (%s, %s, %s)
                                ''',
                                [new_user_id, employee_number, laboratory_section]
                            )

                        cursor.execute(
                            '''
                            INSERT INTO "AuditLog"
                            ("UserID", "Action", "TableName", "RecordID", "Description")
                            VALUES (%s, %s, %s, %s, %s)
                            ''',
                            [
                                current_staff.get("UserID"),
                                "CREATE_STAFF",
                                "Staff",
                                str(new_user_id),
                                f'{current_role} created staff account for {first_name} {last_name} as {role}.'
                            ]
                        )

                return redirect("staff_list")

            except IntegrityError:
                error = "Could not create staff member. Email, phone, license number or registration number may already exist."
            except ValueError as e:
                error = str(e)
            except Exception as e:
                error = f"Could not create staff member: {e}"

    return render(request, "accounts/staff_form.html", {
        "allowed_roles": allowed_roles,
        "departments": departments,
        "error": error,
    })
