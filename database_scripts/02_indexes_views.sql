-- ============================================================
-- CMPG 311 GROUP 16 - HPRS PHASE 3
-- 02_indexes_views.sql
-- PostgreSQL Indexes and Views
-- Hospital Patient Record System (HPRS)
--
-- Purpose:
-- Covers Phase 3 Database Objects marks:
--   - Indexes created (2 marks)
--   - Views implemented effectively (4 marks)
--
-- Run this AFTER:
--   01_create_tables.sql
-- ============================================================

-- ============================================================
-- SECTION A: INDEXES
-- These indexes improve searching, filtering, joins, and reports.
-- ============================================================

-- Patient searches by surname and ID number.
CREATE INDEX IF NOT EXISTS "idx_patient_lastname"
ON "Patient" ("LastName");

CREATE INDEX IF NOT EXISTS "idx_patient_idnumber"
ON "Patient" ("IDNumber");

CREATE INDEX IF NOT EXISTS "idx_patient_city_province"
ON "Patient" ("City", "Province");

-- Appointment scheduling and doctor diary lookups.
CREATE INDEX IF NOT EXISTS "idx_appointment_date"
ON "Appointment" ("AppointmentDate");

CREATE INDEX IF NOT EXISTS "idx_appointment_doctor_date"
ON "Appointment" ("DoctorID", "AppointmentDate");

CREATE INDEX IF NOT EXISTS "idx_appointment_status"
ON "Appointment" ("Status");

-- Admission history and active ward lookup.
CREATE INDEX IF NOT EXISTS "idx_admission_patient"
ON "Admission" ("PatientID");

CREATE INDEX IF NOT EXISTS "idx_admission_doctor"
ON "Admission" ("DoctorID");

CREATE INDEX IF NOT EXISTS "idx_admission_ward"
ON "Admission" ("WardID");

CREATE INDEX IF NOT EXISTS "idx_admission_type"
ON "Admission" ("AdmissionType");

-- Billing reports and outstanding balance queries.
CREATE INDEX IF NOT EXISTS "idx_billing_status"
ON "Billing" ("PaymentStatus");

CREATE INDEX IF NOT EXISTS "idx_billing_patient"
ON "Billing" ("PatientID");

CREATE INDEX IF NOT EXISTS "idx_billing_medicalaid"
ON "Billing" ("MedicalAidID");

-- Clinical and pharmacy searches.
CREATE INDEX IF NOT EXISTS "idx_diagnosis_icd10"
ON "Diagnosis" ("ICD10Code");

CREATE INDEX IF NOT EXISTS "idx_diagnosis_admission"
ON "Diagnosis" ("AdmissionID");

CREATE INDEX IF NOT EXISTS "idx_medication_name"
ON "Medication" ("MedicationName");

CREATE INDEX IF NOT EXISTS "idx_medication_stock"
ON "Medication" ("StockQuantity");

-- Laboratory reports.
CREATE INDEX IF NOT EXISTS "idx_labtest_status"
ON "Laboratory_Test" ("Status");

CREATE INDEX IF NOT EXISTS "idx_labtest_orderdate"
ON "Laboratory_Test" ("OrderDate");

CREATE INDEX IF NOT EXISTS "idx_labtest_admission"
ON "Laboratory_Test" ("AdmissionID");

-- Staff and department lookups.
CREATE INDEX IF NOT EXISTS "idx_staff_role"
ON "Staff" ("Role");

CREATE INDEX IF NOT EXISTS "idx_doctor_department"
ON "Doctor" ("DepartmentID");

CREATE INDEX IF NOT EXISTS "idx_nurseward_ward"
ON "Nurse_Ward" ("WardID");

-- ============================================================
-- SECTION B: VIEWS
-- These views are used for patient profiles, billing summaries,
-- clinical reports, ward reports, and workload dashboards.
-- ============================================================

-- View 1: Patient Summary
CREATE OR REPLACE VIEW "vw_PatientSummary" AS
SELECT
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "FullName",
    p."DateOfBirth",
    DATE_PART('year', AGE(CURRENT_DATE, p."DateOfBirth"))::INT AS "Age",
    p."Gender",
    p."Phone",
    p."Email",
    p."BloodType",
    p."Street",
    p."City",
    p."Province",
    p."PostalCode",
    w."WardName"
FROM "Patient" p
LEFT JOIN "Ward" w
    ON p."WardID" = w."WardID";

-- View 2: Admission and Billing Summary
CREATE OR REPLACE VIEW "vw_AdmissionBillingSummary" AS
SELECT
    a."AdmissionID",
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    a."AdmissionDate",
    a."ExpectedDischargeDate",
    a."ActualDischargeDate",
    a."AdmissionType",
    w."WardName",
    b."BillingID",
    b."BillDate",
    b."TotalAmount",
    b."AmountPaid",
    b."OutstandingBalance",
    b."PaymentStatus",
    ma."SchemeName",
    ma."MemberNumber"
FROM "Admission" a
JOIN "Patient" p
    ON a."PatientID" = p."PatientID"
JOIN "Ward" w
    ON a."WardID" = w."WardID"
LEFT JOIN "Billing" b
    ON a."AdmissionID" = b."AdmissionID"
LEFT JOIN "Medical_Aid" ma
    ON b."MedicalAidID" = ma."MedicalAidID";

-- View 3: Doctor Workload
CREATE OR REPLACE VIEW "vw_DoctorWorkload" AS
SELECT
    d."UserID" AS "DoctorID",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName",
    d."Specialization",
    dep."DepartmentName",
    COUNT(DISTINCT ap."AppointmentID") AS "AppointmentCount",
    COUNT(DISTINCT ad."AdmissionID") AS "AdmissionCount",
    COUNT(DISTINCT dg."DiagnosisID") AS "DiagnosisCount",
    COUNT(DISTINCT pr."PrescriptionID") AS "PrescriptionCount"
FROM "Doctor" d
JOIN "Staff" s
    ON d."UserID" = s."UserID"
JOIN "Department" dep
    ON d."DepartmentID" = dep."DepartmentID"
LEFT JOIN "Appointment" ap
    ON d."UserID" = ap."DoctorID"
LEFT JOIN "Admission" ad
    ON d."UserID" = ad."DoctorID"
LEFT JOIN "Diagnosis" dg
    ON d."UserID" = dg."DoctorID"
LEFT JOIN "Prescription" pr
    ON d."UserID" = pr."DoctorID"
GROUP BY
    d."UserID",
    s."FirstName",
    s."LastName",
    d."Specialization",
    dep."DepartmentName";

-- View 4: Laboratory Results Summary
CREATE OR REPLACE VIEW "vw_LabResultsSummary" AS
SELECT
    lt."TestID",
    lt."TestCode",
    lt."TestDescription",
    lt."OrderDate",
    lt."ResultValue",
    lt."ResultUnit",
    lt."ReferenceRange",
    lt."ResultDate",
    lt."Status",
    a."AdmissionID",
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    lt."DoctorID",
    CONCAT(ds."FirstName", ' ', ds."LastName") AS "DoctorFullName",
    lt."LabTechnicianID",
    CASE
        WHEN lts."UserID" IS NULL THEN NULL
        ELSE CONCAT(lts."FirstName", ' ', lts."LastName")
    END AS "LabTechnicianFullName"
FROM "Laboratory_Test" lt
JOIN "Admission" a
    ON lt."AdmissionID" = a."AdmissionID"
JOIN "Patient" p
    ON a."PatientID" = p."PatientID"
JOIN "Staff" ds
    ON lt."DoctorID" = ds."UserID"
LEFT JOIN "Staff" lts
    ON lt."LabTechnicianID" = lts."UserID";

-- View 5: Ward Occupancy
CREATE OR REPLACE VIEW "vw_WardOccupancy" AS
SELECT
    w."WardID",
    w."WardName",
    w."WardType",
    w."BedCapacity",
    COUNT(a."AdmissionID") FILTER (WHERE a."ActualDischargeDate" IS NULL) AS "CurrentAdmissions",
    (w."BedCapacity" - COUNT(a."AdmissionID") FILTER (WHERE a."ActualDischargeDate" IS NULL)) AS "AvailableBeds"
FROM "Ward" w
LEFT JOIN "Admission" a
    ON w."WardID" = a."WardID"
GROUP BY
    w."WardID",
    w."WardName",
    w."WardType",
    w."BedCapacity";

-- View 6: Prescription Medication Summary
CREATE OR REPLACE VIEW "vw_PrescriptionMedicationSummary" AS
SELECT
    pr."PrescriptionID",
    pr."DateIssued",
    dg."DiagnosisID",
    dg."ICD10Code",
    dg."Description" AS "DiagnosisDescription",
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    m."MedicationID",
    m."MedicationName",
    m."DosageForm",
    m."Strength",
    pm."Quantity",
    pm."Frequency",
    pm."Duration",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName"
FROM "Prescription" pr
JOIN "Diagnosis" dg
    ON pr."DiagnosisID" = dg."DiagnosisID"
JOIN "Admission" a
    ON dg."AdmissionID" = a."AdmissionID"
JOIN "Patient" p
    ON a."PatientID" = p."PatientID"
JOIN "Prescription_Medication" pm
    ON pr."PrescriptionID" = pm."PrescriptionID"
JOIN "Medication" m
    ON pm."MedicationID" = m."MedicationID"
JOIN "Staff" s
    ON pr."DoctorID" = s."UserID";

-- View 7: Outstanding Billing Report
CREATE OR REPLACE VIEW "vw_OutstandingBilling" AS
SELECT
    b."BillingID",
    b."BillDate",
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    p."Phone",
    p."Email",
    b."TotalAmount",
    b."AmountPaid",
    b."OutstandingBalance",
    b."PaymentStatus",
    ma."SchemeName"
FROM "Billing" b
JOIN "Patient" p
    ON b."PatientID" = p."PatientID"
LEFT JOIN "Medical_Aid" ma
    ON b."MedicalAidID" = ma."MedicalAidID"
WHERE b."PaymentStatus" IN ('Pending', 'Partial Payment', 'Overdue');

-- View 8: Active Medical Aid
CREATE OR REPLACE VIEW "vw_ActiveMedicalAid" AS
SELECT
    ma."MedicalAidID",
    ma."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    ma."SchemeName",
    ma."SchemeType",
    ma."MemberNumber",
    ma."CoverageLimit",
    ma."EffectiveDate",
    ma."ExpiryDate",
    CASE
        WHEN CURRENT_DATE BETWEEN ma."EffectiveDate" AND ma."ExpiryDate" THEN 'Active'
        ELSE 'Expired'
    END AS "PolicyStatus"
FROM "Medical_Aid" ma
JOIN "Patient" p
    ON ma."PatientID" = p."PatientID";

-- ============================================================
-- End of 02_indexes_views.sql
-- ============================================================
