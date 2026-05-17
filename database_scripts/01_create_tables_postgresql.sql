-- ============================================================
-- CMPG 311 GROUP 16 - HPRS PHASE 3
-- 01_create_tables.sql
-- PostgreSQL Physical Database Design
-- Hospital Patient Record System (HPRS)
--
-- Purpose:
-- Creates all tables aligned to Phase 2 3NF design:
-- Staff supertype, Doctor/Nurse/Receptionist subtypes,
-- Patient, Allergy weak entity, Appointment, Admission,
-- Diagnosis, Prescription, Medication, Prescription_Medication,
-- Laboratory_Test, Ward, Nurse_Ward, Medical_Aid, Billing,
-- plus LabTechnician, Doctor_Supervision, AuditLog and BillingLog
-- for operational completeness and Phase 3 extra functionality.
--
-- PostgreSQL only. Not SQLite. Not MySQL.
-- ============================================================

-- Optional clean rebuild section.
-- Uncomment only when you intentionally want to reset the database.

DROP TABLE IF EXISTS "BillingLog" CASCADE;
DROP TABLE IF EXISTS "AuditLog" CASCADE;
DROP TABLE IF EXISTS "Billing" CASCADE;
DROP TABLE IF EXISTS "Medical_Aid" CASCADE;
DROP TABLE IF EXISTS "Laboratory_Test" CASCADE;
DROP TABLE IF EXISTS "Prescription_Medication" CASCADE;
DROP TABLE IF EXISTS "Medication" CASCADE;
DROP TABLE IF EXISTS "Prescription" CASCADE;
DROP TABLE IF EXISTS "Diagnosis" CASCADE;
DROP TABLE IF EXISTS "Admission" CASCADE;
DROP TABLE IF EXISTS "Appointment" CASCADE;
DROP TABLE IF EXISTS "Allergy" CASCADE;
DROP TABLE IF EXISTS "Doctor_Supervision" CASCADE;
DROP TABLE IF EXISTS "Nurse_Ward" CASCADE;
DROP TABLE IF EXISTS "Patient" CASCADE;
DROP TABLE IF EXISTS "Ward" CASCADE;
DROP TABLE IF EXISTS "LabTechnician" CASCADE;
DROP TABLE IF EXISTS "Receptionist" CASCADE;
DROP TABLE IF EXISTS "Nurse" CASCADE;
DROP TABLE IF EXISTS "Doctor" CASCADE;
DROP TABLE IF EXISTS "Department" CASCADE;
DROP TABLE IF EXISTS "Staff" CASCADE;

-- ============================================================
-- 1. STAFF SUPERTYPE
-- Phase 2: STAFF(UserID, FirstName, LastName, Phone, Email)
-- Enhanced with Role and account/status fields for RBAC.
-- ============================================================

CREATE TABLE "Staff" (
    "UserID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "FirstName" VARCHAR(100) NOT NULL,
    "LastName" VARCHAR(100) NOT NULL,
    "Phone" VARCHAR(20) UNIQUE,
    "Email" VARCHAR(255) UNIQUE NOT NULL,
    "Role" VARCHAR(30) NOT NULL,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "DateJoined" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pk_staff" PRIMARY KEY ("UserID"),
    CONSTRAINT "chk_staff_role"
        CHECK ("Role" IN (
            'Admin',
            'Doctor',
            'Nurse',
            'Receptionist',
            'BillingOfficer',
            'LabTechnician',
            'ITManager',
            'Patient'
        )),
    CONSTRAINT "chk_staff_email_format"
        CHECK ("Email" LIKE '%@%'),
    CONSTRAINT "chk_staff_phone_format"
        CHECK ("Phone" IS NULL OR "Phone" ~ '^\+?[0-9]{9,15}$')
);

-- ============================================================
-- 2. DEPARTMENT
-- Phase 2: DEPARTMENT(DepartmentID, DepartmentName, Location, ContactExtension)
-- ============================================================

CREATE TABLE "Department" (
    "DepartmentID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "DepartmentName" VARCHAR(100) NOT NULL UNIQUE,
    "Location" VARCHAR(150) NOT NULL,
    "ContactExtension" VARCHAR(10) NOT NULL,

    CONSTRAINT "pk_department" PRIMARY KEY ("DepartmentID"),
    CONSTRAINT "chk_department_extension"
        CHECK ("ContactExtension" ~ '^[0-9]{3,6}$')
);

-- ============================================================
-- 3. DOCTOR SUBTYPE
-- Phase 2: DOCTOR(UserID, Specialization, LicenseNumber, YearsExperience, DepartmentID)
-- UserID is both PK and FK to Staff.
-- ============================================================

CREATE TABLE "Doctor" (
    "UserID" INTEGER NOT NULL,
    "Specialization" VARCHAR(100) NOT NULL,
    "LicenseNumber" VARCHAR(50) NOT NULL UNIQUE,
    "YearsExperience" INTEGER NOT NULL DEFAULT 0,
    "DepartmentID" INTEGER NOT NULL,

    CONSTRAINT "pk_doctor" PRIMARY KEY ("UserID"),
    CONSTRAINT "fk_doctor_staff"
        FOREIGN KEY ("UserID") REFERENCES "Staff"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_doctor_department"
        FOREIGN KEY ("DepartmentID") REFERENCES "Department"("DepartmentID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "chk_doctor_experience"
        CHECK ("YearsExperience" >= 0),
    CONSTRAINT "chk_doctor_license"
        CHECK (LENGTH(TRIM("LicenseNumber")) >= 5)
);

-- ============================================================
-- 4. DOCTOR SUPERVISION RECURSIVE M:N RELATIONSHIP
-- Phase 2 advanced feature: DOCTOR supervises DOCTOR.
-- ============================================================

CREATE TABLE "Doctor_Supervision" (
    "SeniorDoctorID" INTEGER NOT NULL,
    "JuniorDoctorID" INTEGER NOT NULL,
    "StartDate" DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT "pk_doctor_supervision"
        PRIMARY KEY ("SeniorDoctorID", "JuniorDoctorID"),
    CONSTRAINT "fk_supervision_senior"
        FOREIGN KEY ("SeniorDoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_supervision_junior"
        FOREIGN KEY ("JuniorDoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "chk_doctor_not_self_supervise"
        CHECK ("SeniorDoctorID" <> "JuniorDoctorID")
);

-- ============================================================
-- 5. NURSE SUBTYPE
-- Phase 2: NURSE(UserID, RegistrationNo, NurseGrade)
-- ============================================================

CREATE TABLE "Nurse" (
    "UserID" INTEGER NOT NULL,
    "RegistrationNo" VARCHAR(50) NOT NULL UNIQUE,
    "NurseGrade" VARCHAR(50) NOT NULL,

    CONSTRAINT "pk_nurse" PRIMARY KEY ("UserID"),
    CONSTRAINT "fk_nurse_staff"
        FOREIGN KEY ("UserID") REFERENCES "Staff"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "chk_nurse_grade"
        CHECK ("NurseGrade" IN ('Junior', 'Staff Nurse', 'Senior', 'Matron', 'Chief Nursing Officer'))
);

-- ============================================================
-- 6. RECEPTIONIST SUBTYPE
-- Phase 2: RECEPTIONIST(UserID)
-- Enhanced with DeskNumber/DeskAssignment for practical workflow.
-- ============================================================

CREATE TABLE "Receptionist" (
    "UserID" INTEGER NOT NULL,
    "DeskNumber" VARCHAR(20),
    "DeskAssignment" VARCHAR(100),

    CONSTRAINT "pk_receptionist" PRIMARY KEY ("UserID"),
    CONSTRAINT "fk_receptionist_staff"
        FOREIGN KEY ("UserID") REFERENCES "Staff"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- 7. LAB TECHNICIAN SUBTYPE
-- Phase 2 business rules mention Lab Technician for result recording.
-- Added to support BR12 and role-based data responsibility.
-- ============================================================

CREATE TABLE "LabTechnician" (
    "UserID" INTEGER NOT NULL,
    "EmployeeNumber" VARCHAR(50) NOT NULL UNIQUE,
    "LaboratorySection" VARCHAR(100) NOT NULL,

    CONSTRAINT "pk_labtechnician" PRIMARY KEY ("UserID"),
    CONSTRAINT "fk_labtechnician_staff"
        FOREIGN KEY ("UserID") REFERENCES "Staff"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- 8. WARD
-- Phase 2: WARD(WardID, WardName, WardType, BedCapacity, Floor, Location)
-- ============================================================

CREATE TABLE "Ward" (
    "WardID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "WardName" VARCHAR(100) NOT NULL UNIQUE,
    "WardType" VARCHAR(50) NOT NULL,
    "BedCapacity" INTEGER NOT NULL,
    "Floor" VARCHAR(20) NOT NULL,
    "Location" VARCHAR(150) NOT NULL,

    CONSTRAINT "pk_ward" PRIMARY KEY ("WardID"),
    CONSTRAINT "chk_ward_type"
        CHECK ("WardType" IN ('General', 'ICU', 'Paediatric', 'Maternity', 'Emergency', 'Surgical', 'Medical')),
    CONSTRAINT "chk_ward_capacity"
        CHECK ("BedCapacity" > 0)
);

-- ============================================================
-- 9. PATIENT
-- Phase 2: PATIENT(PatientID, FirstName, LastName, DateOfBirth,
-- Gender, Phone, Email, Street, City, Province, PostalCode,
-- IDNumber, BloodType, EmergencyContactName, EmergencyContactPhone)
-- Age is not stored; calculate from DateOfBirth.
-- ============================================================

CREATE TABLE "Patient" (
    "PatientID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "FirstName" VARCHAR(100) NOT NULL,
    "LastName" VARCHAR(100) NOT NULL,
    "DateOfBirth" DATE NOT NULL,
    "Gender" VARCHAR(20) NOT NULL,
    "Phone" VARCHAR(20) UNIQUE,
    "Email" VARCHAR(255) UNIQUE,
    "Street" VARCHAR(150) NOT NULL,
    "City" VARCHAR(100) NOT NULL,
    "Province" VARCHAR(100) NOT NULL,
    "PostalCode" VARCHAR(10) NOT NULL,
    "IDNumber" CHAR(13) UNIQUE,
    "PassportNumber" VARCHAR(30) UNIQUE,
    "BloodType" VARCHAR(5),
    "EmergencyContactName" VARCHAR(150),
    "EmergencyContactPhone" VARCHAR(20),
    "WardID" INTEGER,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pk_patient" PRIMARY KEY ("PatientID"),
    CONSTRAINT "fk_patient_ward"
        FOREIGN KEY ("WardID") REFERENCES "Ward"("WardID")
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT "chk_patient_gender"
        CHECK ("Gender" IN ('Male', 'Female', 'Other')),
    CONSTRAINT "chk_patient_contact_method"
        CHECK ("Phone" IS NOT NULL OR "Email" IS NOT NULL),
    CONSTRAINT "chk_patient_id_or_passport"
        CHECK ("IDNumber" IS NOT NULL OR "PassportNumber" IS NOT NULL),
    CONSTRAINT "chk_patient_id_length"
        CHECK ("IDNumber" IS NULL OR "IDNumber" ~ '^[0-9]{13}$'),
    CONSTRAINT "chk_patient_phone_format"
        CHECK ("Phone" IS NULL OR "Phone" ~ '^\+?[0-9]{9,15}$'),
    CONSTRAINT "chk_patient_email_format"
        CHECK ("Email" IS NULL OR "Email" LIKE '%@%'),
    CONSTRAINT "chk_patient_postalcode"
        CHECK ("PostalCode" ~ '^[0-9]{4}$'),
    CONSTRAINT "chk_patient_blood_type"
        CHECK ("BloodType" IS NULL OR "BloodType" IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    CONSTRAINT "chk_patient_dob_not_future"
        CHECK ("DateOfBirth" <= CURRENT_DATE),
    CONSTRAINT "chk_patient_minor_emergency_contact"
        CHECK (
            "DateOfBirth" <= (CURRENT_DATE - INTERVAL '18 years')
            OR ("EmergencyContactName" IS NOT NULL AND "EmergencyContactPhone" IS NOT NULL)
        )
);

-- ============================================================
-- 10. ALLERGY WEAK ENTITY
-- Phase 2: ALLERGY(PatientID, AllergyName, Severity, DateRecorded)
-- Composite PK: PatientID + AllergyName.
-- ============================================================

CREATE TABLE "Allergy" (
    "PatientID" INTEGER NOT NULL,
    "AllergyName" VARCHAR(100) NOT NULL,
    "Severity" VARCHAR(20) NOT NULL,
    "DateRecorded" DATE NOT NULL DEFAULT CURRENT_DATE,
    "Notes" TEXT,

    CONSTRAINT "pk_allergy"
        PRIMARY KEY ("PatientID", "AllergyName"),
    CONSTRAINT "fk_allergy_patient"
        FOREIGN KEY ("PatientID") REFERENCES "Patient"("PatientID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "chk_allergy_severity"
        CHECK ("Severity" IN ('Mild', 'Moderate', 'Severe', 'Critical')),
    CONSTRAINT "chk_allergy_date"
        CHECK ("DateRecorded" <= CURRENT_DATE)
);

-- ============================================================
-- 11. NURSE_WARD BRIDGE ENTITY
-- Phase 2: NURSE_WARD(UserID, WardID, AssignmentDate, ShiftType)
-- Composite PK: UserID + WardID.
-- ============================================================

CREATE TABLE "Nurse_Ward" (
    "UserID" INTEGER NOT NULL,
    "WardID" INTEGER NOT NULL,
    "AssignmentDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "ShiftType" VARCHAR(20) NOT NULL,

    CONSTRAINT "pk_nurse_ward"
        PRIMARY KEY ("UserID", "WardID"),
    CONSTRAINT "fk_nurseward_nurse"
        FOREIGN KEY ("UserID") REFERENCES "Nurse"("UserID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_nurseward_ward"
        FOREIGN KEY ("WardID") REFERENCES "Ward"("WardID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "chk_nurseward_shift"
        CHECK ("ShiftType" IN ('Day', 'Night', 'Emergency'))
);

-- ============================================================
-- 12. APPOINTMENT
-- Phase 2: APPOINTMENT(AppointmentID, AppointmentDate, AppointmentTime,
-- Status, PatientID, UserID FK -> DOCTOR)
-- Added ReceptionistID to support BR04/BR05 operational actor.
-- ============================================================

CREATE TABLE "Appointment" (
    "AppointmentID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "AppointmentDate" DATE NOT NULL,
    "AppointmentTime" TIME NOT NULL,
    "Status" VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    "Reason" TEXT,
    "PatientID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,
    "ReceptionistID" INTEGER,

    CONSTRAINT "pk_appointment" PRIMARY KEY ("AppointmentID"),
    CONSTRAINT "fk_appointment_patient"
        FOREIGN KEY ("PatientID") REFERENCES "Patient"("PatientID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_appointment_doctor"
        FOREIGN KEY ("DoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_appointment_receptionist"
        FOREIGN KEY ("ReceptionistID") REFERENCES "Receptionist"("UserID")
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT "chk_appointment_status"
        CHECK ("Status" IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    CONSTRAINT "uq_doctor_appointment_slot"
        UNIQUE ("DoctorID", "AppointmentDate", "AppointmentTime")
);

-- ============================================================
-- 13. ADMISSION
-- Phase 2: ADMISSION(AdmissionID, AdmissionDate, ExpectedDischargeDate,
-- ActualDischargeDate, AdmissionType, PatientID, UserID, WardID)
-- ============================================================

CREATE TABLE "Admission" (
    "AdmissionID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "AdmissionDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "ExpectedDischargeDate" DATE NOT NULL,
    "ActualDischargeDate" DATE,
    "AdmissionType" VARCHAR(20) NOT NULL,
    "BedNumber" VARCHAR(20) NOT NULL,
    "PatientID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,
    "WardID" INTEGER NOT NULL,

    CONSTRAINT "pk_admission" PRIMARY KEY ("AdmissionID"),
    CONSTRAINT "fk_admission_patient"
        FOREIGN KEY ("PatientID") REFERENCES "Patient"("PatientID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_admission_doctor"
        FOREIGN KEY ("DoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_admission_ward"
        FOREIGN KEY ("WardID") REFERENCES "Ward"("WardID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "chk_admission_type"
        CHECK ("AdmissionType" IN ('Inpatient', 'Outpatient')),
    CONSTRAINT "chk_expected_discharge"
        CHECK ("ExpectedDischargeDate" >= "AdmissionDate"),
    CONSTRAINT "chk_actual_discharge"
        CHECK ("ActualDischargeDate" IS NULL OR "ActualDischargeDate" >= "AdmissionDate"),
    CONSTRAINT "uq_ward_bed_active"
        UNIQUE ("WardID", "BedNumber", "ActualDischargeDate")
);

-- ============================================================
-- 14. DIAGNOSIS
-- Phase 2: DIAGNOSIS(DiagnosisID, ICD10Code, Description, Severity,
-- DiagnosisDate, AdmissionID, UserID FK -> DOCTOR)
-- ============================================================

CREATE TABLE "Diagnosis" (
    "DiagnosisID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "ICD10Code" VARCHAR(10) NOT NULL,
    "Description" TEXT NOT NULL,
    "Severity" VARCHAR(20) NOT NULL,
    "DiagnosisDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "AdmissionID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,

    CONSTRAINT "pk_diagnosis" PRIMARY KEY ("DiagnosisID"),
    CONSTRAINT "fk_diagnosis_admission"
        FOREIGN KEY ("AdmissionID") REFERENCES "Admission"("AdmissionID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_diagnosis_doctor"
        FOREIGN KEY ("DoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "chk_diagnosis_severity"
        CHECK ("Severity" IN ('Mild', 'Moderate', 'Severe', 'Critical')),
    CONSTRAINT "chk_icd10_format"
        CHECK ("ICD10Code" ~ '^[A-Z][0-9]{2}(\.[0-9A-Z]{1,4})?$')
);

-- ============================================================
-- 15. PRESCRIPTION
-- Phase 2: PRESCRIPTION(PrescriptionID, DateIssued,
-- DosageInstructions, DiagnosisID, UserID FK -> DOCTOR)
-- ============================================================

CREATE TABLE "Prescription" (
    "PrescriptionID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "DateIssued" DATE NOT NULL DEFAULT CURRENT_DATE,
    "DosageInstructions" TEXT NOT NULL,
    "DiagnosisID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,

    CONSTRAINT "pk_prescription" PRIMARY KEY ("PrescriptionID"),
    CONSTRAINT "fk_prescription_diagnosis"
        FOREIGN KEY ("DiagnosisID") REFERENCES "Diagnosis"("DiagnosisID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_prescription_doctor"
        FOREIGN KEY ("DoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
-- 16. MEDICATION
-- Phase 2: MEDICATION(MedicationID, MedicationName,
-- DosageForm, Strength, Category, StockQuantity)
-- ============================================================

CREATE TABLE "Medication" (
    "MedicationID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "MedicationName" VARCHAR(150) NOT NULL UNIQUE,
    "DosageForm" VARCHAR(50) NOT NULL,
    "Strength" VARCHAR(50) NOT NULL,
    "Category" VARCHAR(100) NOT NULL,
    "StockQuantity" INTEGER NOT NULL DEFAULT 0,
    "ReorderLevel" INTEGER NOT NULL DEFAULT 10,

    CONSTRAINT "pk_medication" PRIMARY KEY ("MedicationID"),
    CONSTRAINT "chk_med_stock"
        CHECK ("StockQuantity" >= 0),
    CONSTRAINT "chk_med_reorder"
        CHECK ("ReorderLevel" >= 0)
);

-- ============================================================
-- 17. PRESCRIPTION_MEDICATION BRIDGE ENTITY
-- Phase 2: PRESCRIPTION_MEDICATION(PrescriptionID, MedicationID,
-- Quantity, Frequency, Duration)
-- Composite PK resolves Prescription M:N Medication.
-- ============================================================

CREATE TABLE "Prescription_Medication" (
    "PrescriptionID" INTEGER NOT NULL,
    "MedicationID" INTEGER NOT NULL,
    "Quantity" INTEGER NOT NULL,
    "Frequency" VARCHAR(100) NOT NULL,
    "Duration" VARCHAR(100) NOT NULL,

    CONSTRAINT "pk_prescription_medication"
        PRIMARY KEY ("PrescriptionID", "MedicationID"),
    CONSTRAINT "fk_pm_prescription"
        FOREIGN KEY ("PrescriptionID") REFERENCES "Prescription"("PrescriptionID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_pm_medication"
        FOREIGN KEY ("MedicationID") REFERENCES "Medication"("MedicationID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "chk_pm_quantity"
        CHECK ("Quantity" > 0)
);

-- ============================================================
-- 18. LABORATORY_TEST WEAK ENTITY
-- Phase 2: LABORATORY_TEST(TestID, TestCode, TestDescription,
-- OrderDate, ResultValue, ResultUnit, ReferenceRange, ResultDate,
-- AdmissionID, UserID FK -> DOCTOR)
-- Added LabTechnicianID and Status to support result recording.
-- ============================================================

CREATE TABLE "Laboratory_Test" (
    "TestID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "TestCode" VARCHAR(30) NOT NULL,
    "TestDescription" TEXT NOT NULL,
    "OrderDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "ResultValue" VARCHAR(100),
    "ResultUnit" VARCHAR(50),
    "ReferenceRange" VARCHAR(100),
    "ResultDate" DATE,
    "Status" VARCHAR(20) NOT NULL DEFAULT 'Ordered',
    "AdmissionID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,
    "LabTechnicianID" INTEGER,

    CONSTRAINT "pk_laboratory_test" PRIMARY KEY ("TestID"),
    CONSTRAINT "fk_labtest_admission"
        FOREIGN KEY ("AdmissionID") REFERENCES "Admission"("AdmissionID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_labtest_doctor"
        FOREIGN KEY ("DoctorID") REFERENCES "Doctor"("UserID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_labtest_technician"
        FOREIGN KEY ("LabTechnicianID") REFERENCES "LabTechnician"("UserID")
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT "chk_labtest_status"
        CHECK ("Status" IN ('Ordered', 'In Progress', 'Resulted', 'Cancelled')),
    CONSTRAINT "chk_lab_result_date"
        CHECK ("ResultDate" IS NULL OR "ResultDate" >= "OrderDate"),
    CONSTRAINT "chk_lab_result_required_when_resulted"
        CHECK (
            "Status" <> 'Resulted'
            OR ("ResultValue" IS NOT NULL AND "ResultUnit" IS NOT NULL AND "ReferenceRange" IS NOT NULL AND "ResultDate" IS NOT NULL)
        )
);

-- ============================================================
-- 19. MEDICAL_AID
-- Phase 2: MEDICAL_AID(MedicalAidID, SchemeName, SchemeType,
-- MemberNumber, CoverageLimit, EffectiveDate, ExpiryDate, PatientID)
-- ============================================================

CREATE TABLE "Medical_Aid" (
    "MedicalAidID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "SchemeName" VARCHAR(150) NOT NULL,
    "SchemeType" VARCHAR(100) NOT NULL,
    "MemberNumber" VARCHAR(50) NOT NULL,
    "CoverageLimit" NUMERIC(12,2) NOT NULL DEFAULT 0,
    "EffectiveDate" DATE NOT NULL,
    "ExpiryDate" DATE NOT NULL,
    "PatientID" INTEGER NOT NULL,

    CONSTRAINT "pk_medical_aid" PRIMARY KEY ("MedicalAidID"),
    CONSTRAINT "fk_medicalaid_patient"
        FOREIGN KEY ("PatientID") REFERENCES "Patient"("PatientID")
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "uq_medicalaid_scheme_member"
        UNIQUE ("SchemeName", "MemberNumber"),
    CONSTRAINT "chk_medicalaid_dates"
        CHECK ("EffectiveDate" < "ExpiryDate"),
    CONSTRAINT "chk_medicalaid_coverage"
        CHECK ("CoverageLimit" >= 0)
);

-- ============================================================
-- 20. BILLING
-- Phase 2: BILLING(BillingID, BillDate, TotalAmount, AmountPaid,
-- OutstandingBalance, PaymentStatus, AdmissionID, PatientID, MedicalAidID)
-- Admission -> Billing is mandatory 1:1 via UNIQUE AdmissionID.
-- ============================================================

CREATE TABLE "Billing" (
    "BillingID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "BillDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "TotalAmount" NUMERIC(12,2) NOT NULL,
    "AmountPaid" NUMERIC(12,2) NOT NULL DEFAULT 0,
    "OutstandingBalance" NUMERIC(12,2) GENERATED ALWAYS AS ("TotalAmount" - "AmountPaid") STORED,
    "PaymentStatus" VARCHAR(30) NOT NULL DEFAULT 'Pending',
    "AdmissionID" INTEGER NOT NULL UNIQUE,
    "PatientID" INTEGER NOT NULL,
    "MedicalAidID" INTEGER,

    CONSTRAINT "pk_billing" PRIMARY KEY ("BillingID"),
    CONSTRAINT "fk_billing_admission"
        FOREIGN KEY ("AdmissionID") REFERENCES "Admission"("AdmissionID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_billing_patient"
        FOREIGN KEY ("PatientID") REFERENCES "Patient"("PatientID")
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT "fk_billing_medicalaid"
        FOREIGN KEY ("MedicalAidID") REFERENCES "Medical_Aid"("MedicalAidID")
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT "chk_billing_amounts"
        CHECK ("TotalAmount" >= 0 AND "AmountPaid" >= 0 AND "AmountPaid" <= "TotalAmount"),
    CONSTRAINT "chk_billing_status"
        CHECK ("PaymentStatus" IN ('Paid', 'Pending', 'Partial Payment', 'Overdue', 'Cancelled'))
);

-- ============================================================
-- 21. BILLING LOG
-- Extra table for trigger demonstration in Phase 3.
-- ============================================================

CREATE TABLE "BillingLog" (
    "BillingLogID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "BillingID" INTEGER NOT NULL,
    "TotalAmount" NUMERIC(12,2) NOT NULL,
    "AmountPaid" NUMERIC(12,2) NOT NULL,
    "OutstandingBalance" NUMERIC(12,2) NOT NULL,
    "PaymentStatus" VARCHAR(30) NOT NULL,
    "LogAction" VARCHAR(50) NOT NULL DEFAULT 'INSERT',
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pk_billinglog" PRIMARY KEY ("BillingLogID"),
    CONSTRAINT "fk_billinglog_billing"
        FOREIGN KEY ("BillingID") REFERENCES "Billing"("BillingID")
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- 22. AUDIT LOG
-- Extra table to support POPIA/RBAC auditability.
-- ============================================================

CREATE TABLE "AuditLog" (
    "AuditID" INTEGER GENERATED ALWAYS AS IDENTITY,
    "UserID" INTEGER,
    "Action" VARCHAR(100) NOT NULL,
    "TableName" VARCHAR(100) NOT NULL,
    "RecordID" VARCHAR(100) NOT NULL,
    "Description" TEXT,
    "Timestamp" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pk_auditlog" PRIMARY KEY ("AuditID"),
    CONSTRAINT "fk_auditlog_staff"
        FOREIGN KEY ("UserID") REFERENCES "Staff"("UserID")
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- ============================================================
-- End of 01_create_tables.sql
-- ============================================================
