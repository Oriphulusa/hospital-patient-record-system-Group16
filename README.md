# Hospital Patient Record System (Django)

A clean, role-based hospital management platform built with Django + Bootstrap 5.

## Roles
- **Admin** (also acts as Receptionist): manage users, patients, appointments, wards/beds, billing, insurance.
- **Doctor**: view assigned patients, consultations, prescriptions (pharmacy), lab orders, ward assignments.
- **Nurse**: vitals, ward/bed care, view patient records.
- **Patient**: view own records, appointments, prescriptions, bills.

## Setup
```bash
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed        # creates demo users + sample data
python manage.py runserver
```

## Demo Logins (password: `password123` for all)
- admin / password123
- doctor1 / password123
- nurse1 / password123
- patient1 / password123

Visit http://127.0.0.1:8000/
---

## Recent Updates
- Improved system documentation for clearer role separation and setup steps
- Standardised project structure for hospital management workflow
- Enhanced readability of installation instructions for new developers Test update for contributor tracking

