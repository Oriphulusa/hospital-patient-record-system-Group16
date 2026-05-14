-- ============================================================
-- CMPG 311 GROUP 16 - HPRS PHASE 3
-- 03_sample_data.sql
-- PostgreSQL Sample Data
-- Hospital Patient Record System (HPRS)
--
-- Purpose:
-- Covers Phase 3 Database Objects mark:
--   - Data populated correctly in tables (4 marks)
--
-- Run this AFTER:
--   01_create_tables.sql
--   02_indexes_views.sql
--
-- PostgreSQL only.
-- ============================================================

-- ============================================================
-- CLEAN SAMPLE DATA SECTION
-- Deletes sample data in dependency-safe order.
-- Keeps the table structures, indexes, and views.
-- ============================================================

DELETE FROM "AuditLog";
DELETE FROM "BillingLog";
DELETE FROM "Billing";
DELETE FROM "Medical_Aid";
DELETE FROM "Laboratory_Test";
DELETE FROM "Prescription_Medication";
DELETE FROM "Medication";
DELETE FROM "Prescription";
DELETE FROM "Diagnosis";
DELETE FROM "Admission";
DELETE FROM "Appointment";
DELETE FROM "Allergy";
DELETE FROM "Doctor_Supervision";
DELETE FROM "Nurse_Ward";
DELETE FROM "Patient";
DELETE FROM "Ward";
DELETE FROM "LabTechnician";
DELETE FROM "Receptionist";
DELETE FROM "Nurse";
DELETE FROM "Doctor";
DELETE FROM "Department";
DELETE FROM "Staff";

-- ============================================================
-- 1. DEPARTMENTS
-- ============================================================

INSERT INTO "Department"
("DepartmentID", "DepartmentName", "Location", "ContactExtension")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Cardiology', 'Block A - Floor 2', '2101'),
(2, 'Paediatrics', 'Block B - Floor 1', '1102'),
(3, 'General Medicine', 'Block A - Floor 1', '1101'),
(4, 'Orthopaedics', 'Block C - Floor 3', '3301'),
(5, 'Laboratory', 'Block D - Ground Floor', '0401'),
(6, 'Administration', 'Main Reception', '0001');

-- ============================================================
-- 2. STAFF
-- Roles support RBAC and hospital workflow.
-- ============================================================

INSERT INTO "Staff"
("UserID", "FirstName", "LastName", "Phone", "Email", "Role", "IsActive")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Nomsa', 'Mokoena', '+27821230001', 'admin@hprs.co.za', 'Admin', TRUE),
(2, 'Thabo', 'Dlamini', '+27821230002', 'dr.dlamini@hprs.co.za', 'Doctor', TRUE),
(3, 'Aisha', 'Patel', '+27821230003', 'dr.patel@hprs.co.za', 'Doctor', TRUE),
(4, 'Karabo', 'Molefe', '+27821230004', 'dr.molefe@hprs.co.za', 'Doctor', TRUE),
(5, 'Michael', 'Naidoo', '+27821230005', 'dr.naidoo@hprs.co.za', 'Doctor', TRUE),
(6, 'Lerato', 'Nkosi', '+27821230006', 'nurse.nkosi@hprs.co.za', 'Nurse', TRUE),
(7, 'Bongani', 'Maseko', '+27821230007', 'nurse.maseko@hprs.co.za', 'Nurse', TRUE),
(8, 'Zanele', 'Khumalo', '+27821230008', 'reception1@hprs.co.za', 'Receptionist', TRUE),
(9, 'Sipho', 'Mthembu', '+27821230009', 'reception2@hprs.co.za', 'Receptionist', TRUE),
(10, 'Naledi', 'Sibanda', '+27821230010', 'billing@hprs.co.za', 'BillingOfficer', TRUE),
(11, 'Peter', 'van Wyk', '+27821230011', 'lab@hprs.co.za', 'LabTechnician', TRUE),
(12, 'Olebogeng', 'Tau', '+27821230012', 'itmanager@hprs.co.za', 'ITManager', TRUE),
(13, 'Mpho', 'Ndlovu', '+27821230013', 'patient.demo@hprs.co.za', 'Patient', TRUE);

-- ============================================================
-- 3. STAFF SUBTYPES
-- ============================================================

INSERT INTO "Doctor"
("UserID", "Specialization", "LicenseNumber", "YearsExperience", "DepartmentID")
VALUES
(2, 'Cardiologist', 'HPCSA-MP10021', 12, 1),
(3, 'Paediatrician', 'HPCSA-MP10022', 9, 2),
(4, 'General Physician', 'HPCSA-MP10023', 7, 3),
(5, 'Orthopaedic Surgeon', 'HPCSA-MP10024', 14, 4);

INSERT INTO "Doctor_Supervision"
("SeniorDoctorID", "JuniorDoctorID", "StartDate")
VALUES
(2, 4, '2025-01-15'),
(5, 3, '2025-03-01');

INSERT INTO "Nurse"
("UserID", "RegistrationNo", "NurseGrade")
VALUES
(6, 'SANC-2024-1006', 'Senior'),
(7, 'SANC-2024-1007', 'Staff Nurse');

INSERT INTO "Receptionist"
("UserID", "DeskNumber", "DeskAssignment")
VALUES
(8, 'R01', 'Main Reception'),
(9, 'R02', 'Outpatient Reception');

INSERT INTO "LabTechnician"
("UserID", "EmployeeNumber", "LaboratorySection")
VALUES
(11, 'LAB-2026-001', 'Haematology and Chemistry');

-- ============================================================
-- 4. WARDS
-- ============================================================

INSERT INTO "Ward"
("WardID", "WardName", "WardType", "BedCapacity", "Floor", "Location")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'General Ward A', 'General', 30, '1', 'Block A'),
(2, 'ICU Ward', 'ICU', 10, '2', 'Block A'),
(3, 'Paediatric Ward', 'Paediatric', 20, '1', 'Block B'),
(4, 'Maternity Ward', 'Maternity', 15, '2', 'Block B'),
(5, 'Emergency Ward', 'Emergency', 12, 'Ground', 'Block C');

-- ============================================================
-- 5. PATIENTS
-- At least one contact method is required.
-- Age is not stored; it is calculated from DateOfBirth.
-- ============================================================

INSERT INTO "Patient"
("PatientID", "FirstName", "LastName", "DateOfBirth", "Gender", "Phone", "Email",
 "Street", "City", "Province", "PostalCode", "IDNumber", "PassportNumber",
 "BloodType", "EmergencyContactName", "EmergencyContactPhone", "WardID")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Mpho', 'Ndlovu', '1998-04-12', 'Male', '+27831234561', 'mpho.ndlovu@example.com',
 '12 Nelson Mandela Drive', 'Mahikeng', 'North West', '2745', '9804125800081', NULL,
 'O+', 'Thandi Ndlovu', '+27839870001', NULL),

(2, 'Ayanda', 'Mabena', '2001-08-23', 'Female', '+27831234562', 'ayanda.mabena@example.com',
 '45 Steve Biko Road', 'Pretoria', 'Gauteng', '0002', '0108230400082', NULL,
 'A+', 'Sibusiso Mabena', '+27839870002', NULL),

(3, 'Lethabo', 'Mokoena', '2012-11-05', 'Male', '+27831234563', 'lethabo.mokoena@example.com',
 '88 Church Street', 'Johannesburg', 'Gauteng', '2001', '1211055800083', NULL,
 'B+', 'Nomvula Mokoena', '+27839870003', 3),

(4, 'Zinhle', 'Khumalo', '1985-02-18', 'Female', '+27831234564', 'zinhle.khumalo@example.com',
 '19 Long Street', 'Cape Town', 'Western Cape', '8001', '8502180400084', NULL,
 'AB+', 'Bheki Khumalo', '+27839870004', NULL),

(5, 'Tshepo', 'Molefe', '1979-06-30', 'Male', '+27831234565', 'tshepo.molefe@example.com',
 '77 Dr James Moroka Avenue', 'Mahikeng', 'North West', '2745', '7906305800085', NULL,
 'A-', 'Kagiso Molefe', '+27839870005', 1),

(6, 'Nandi', 'Nkosi', '1995-09-14', 'Female', '+27831234566', 'nandi.nkosi@example.com',
 '5 Florida Road', 'Durban', 'KwaZulu-Natal', '4001', '9509140400086', NULL,
 'O-', 'Themba Nkosi', '+27839870006', NULL),

(7, 'Kabelo', 'Radebe', '1990-01-25', 'Male', '+27831234567', 'kabelo.radebe@example.com',
 '101 Vilakazi Street', 'Soweto', 'Gauteng', '1804', '9001255800087', NULL,
 'B-', 'Palesa Radebe', '+27839870007', 2),

(8, 'Palesa', 'Tshabalala', '2004-03-09', 'Female', '+27831234568', 'palesa.tshabalala@example.com',
 '28 Loop Street', 'Cape Town', 'Western Cape', '8001', '0403090400088', NULL,
 'A+', 'Refilwe Tshabalala', '+27839870008', NULL),

(9, 'Siphesihle', 'Dube', '2010-07-21', 'Male', '+27831234569', 'siphesihle.dube@example.com',
 '33 Pixley ka Seme Street', 'Durban', 'KwaZulu-Natal', '4001', '1007215800089', NULL,
 'O+', 'Lindiwe Dube', '+27839870009', 3),

(10, 'Boitumelo', 'Seko', '1999-12-02', 'Female', '+27831234570', 'boitumelo.seko@example.com',
 '6 University Road', 'Potchefstroom', 'North West', '2531', '9912020400090', NULL,
 'AB-', 'Kgomotso Seko', '+27839870010', NULL);

-- ============================================================
-- 6. ALLERGIES
-- Composite key: PatientID + AllergyName.
-- ============================================================

INSERT INTO "Allergy"
("PatientID", "AllergyName", "Severity", "DateRecorded", "Notes")
VALUES
(1, 'Penicillin', 'Severe', '2026-04-01', 'Patient reports rash and breathing difficulty.'),
(3, 'Peanuts', 'Critical', '2026-04-05', 'High risk allergy. Avoid peanut-containing medication.'),
(5, 'Latex', 'Moderate', '2026-04-10', 'Use latex-free gloves.'),
(7, 'Aspirin', 'Severe', '2026-04-12', 'Avoid aspirin-based pain medication.'),
(9, 'Sulfa Drugs', 'Moderate', '2026-04-16', 'Monitor antibiotic prescriptions.');

-- ============================================================
-- 7. NURSE-WARD ASSIGNMENTS
-- Composite key: UserID + WardID.
-- ============================================================

INSERT INTO "Nurse_Ward"
("UserID", "WardID", "AssignmentDate", "ShiftType")
VALUES
(6, 1, '2026-05-01', 'Day'),
(6, 2, '2026-05-01', 'Emergency'),
(7, 3, '2026-05-01', 'Night'),
(7, 5, '2026-05-01', 'Day');

-- ============================================================
-- 8. APPOINTMENTS
-- ============================================================

INSERT INTO "Appointment"
("AppointmentID", "AppointmentDate", "AppointmentTime", "Status", "Reason",
 "PatientID", "DoctorID", "ReceptionistID")
OVERRIDING SYSTEM VALUE
VALUES
(1, CURRENT_DATE, '09:00', 'Scheduled', 'Chest pain and shortness of breath', 1, 2, 8),
(2, CURRENT_DATE, '10:00', 'Scheduled', 'Child fever and cough', 3, 3, 8),
(3, CURRENT_DATE - INTERVAL '1 day', '11:00', 'Completed', 'Back pain and mobility issue', 5, 5, 9),
(4, CURRENT_DATE + INTERVAL '2 days', '14:00', 'Scheduled', 'Routine check-up', 2, 4, 8),
(5, CURRENT_DATE - INTERVAL '3 days', '08:30', 'No-Show', 'Follow-up appointment', 6, 4, 9),
(6, CURRENT_DATE - INTERVAL '2 days', '13:00', 'Cancelled', 'Cardiology review', 7, 2, 8),
(7, CURRENT_DATE + INTERVAL '1 day', '15:00', 'Scheduled', 'Paediatric review', 9, 3, 9),
(8, CURRENT_DATE, '16:00', 'Scheduled', 'General consultation', 10, 4, 8);

-- ============================================================
-- 9. ADMISSIONS
-- ============================================================

INSERT INTO "Admission"
("AdmissionID", "AdmissionDate", "ExpectedDischargeDate", "ActualDischargeDate",
 "AdmissionType", "BedNumber", "PatientID", "DoctorID", "WardID")
OVERRIDING SYSTEM VALUE
VALUES
(1, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '4 days',
 'Inpatient', 'A-101', 5, 5, 1),

(2, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '2 days', NULL,
 'Inpatient', 'ICU-02', 7, 2, 2),

(3, CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '3 days', NULL,
 'Inpatient', 'P-014', 3, 3, 3),

(4, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '1 day', NULL,
 'Outpatient', 'E-007', 1, 2, 5),

(5, CURRENT_DATE, CURRENT_DATE + INTERVAL '2 days', NULL,
 'Inpatient', 'P-015', 9, 3, 3);

-- ============================================================
-- 10. DIAGNOSES
-- ICD10Code uses valid format.
-- ============================================================

INSERT INTO "Diagnosis"
("DiagnosisID", "ICD10Code", "Description", "Severity", "DiagnosisDate", "AdmissionID", "DoctorID")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'M54.5', 'Lower back pain with suspected lumbar strain', 'Moderate', CURRENT_DATE - INTERVAL '9 days', 1, 5),
(2, 'I20.9', 'Angina pectoris, unspecified', 'Severe', CURRENT_DATE - INTERVAL '4 days', 2, 2),
(3, 'J06.9', 'Acute upper respiratory infection, unspecified', 'Mild', CURRENT_DATE - INTERVAL '1 day', 3, 3),
(4, 'R07.4', 'Chest pain, unspecified', 'Moderate', CURRENT_DATE, 4, 2),
(5, 'R50.9', 'Fever, unspecified', 'Moderate', CURRENT_DATE, 5, 3);

-- ============================================================
-- 11. PRESCRIPTIONS
-- ============================================================

INSERT INTO "Prescription"
("PrescriptionID", "DateIssued", "DosageInstructions", "DiagnosisID", "DoctorID")
OVERRIDING SYSTEM VALUE
VALUES
(1, CURRENT_DATE - INTERVAL '9 days', 'Take medication after meals. Avoid heavy lifting.', 1, 5),
(2, CURRENT_DATE - INTERVAL '4 days', 'Administer as directed. Monitor blood pressure twice daily.', 2, 2),
(3, CURRENT_DATE - INTERVAL '1 day', 'Take medication three times daily for symptoms.', 3, 3),
(4, CURRENT_DATE, 'Use only if pain persists. Monitor for allergic reaction.', 4, 2),
(5, CURRENT_DATE, 'Paediatric dose according to weight. Maintain hydration.', 5, 3);

-- ============================================================
-- 12. MEDICATIONS
-- ============================================================

INSERT INTO "Medication"
("MedicationID", "MedicationName", "DosageForm", "Strength", "Category", "StockQuantity", "ReorderLevel")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Paracetamol', 'Tablet', '500mg', 'Analgesic', 500, 100),
(2, 'Ibuprofen', 'Tablet', '200mg', 'Anti-inflammatory', 60, 80),
(3, 'Amoxicillin', 'Capsule', '500mg', 'Antibiotic', 250, 50),
(4, 'Amlodipine', 'Tablet', '5mg', 'Antihypertensive', 120, 40),
(5, 'Salbutamol', 'Inhaler', '100mcg', 'Bronchodilator', 30, 20),
(6, 'Cefuroxime', 'Tablet', '250mg', 'Antibiotic', 45, 50),
(7, 'Diclofenac Gel', 'Gel', '1%', 'Topical Anti-inflammatory', 25, 15);

-- ============================================================
-- 13. PRESCRIPTION-MEDICATION BRIDGE
-- ============================================================

INSERT INTO "Prescription_Medication"
("PrescriptionID", "MedicationID", "Quantity", "Frequency", "Duration")
VALUES
(1, 2, 20, 'Twice daily', '5 days'),
(1, 7, 1, 'Apply twice daily', '7 days'),
(2, 4, 30, 'Once daily', '30 days'),
(3, 1, 12, 'Three times daily', '4 days'),
(4, 5, 1, 'Two puffs when needed', '7 days'),
(5, 1, 10, 'Three times daily', '3 days'),
(5, 6, 14, 'Twice daily', '7 days');

-- ============================================================
-- 14. LABORATORY TESTS
-- ============================================================

INSERT INTO "Laboratory_Test"
("TestID", "TestCode", "TestDescription", "OrderDate",
 "ResultValue", "ResultUnit", "ReferenceRange", "ResultDate", "Status",
 "AdmissionID", "DoctorID", "LabTechnicianID")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'FBC', 'Full blood count', CURRENT_DATE - INTERVAL '4 days',
 '7.2', 'x10^9/L', '4.0-11.0', CURRENT_DATE - INTERVAL '3 days', 'Resulted',
 2, 2, 11),

(2, 'CRP', 'C-reactive protein', CURRENT_DATE - INTERVAL '1 day',
 '18', 'mg/L', '<10', CURRENT_DATE, 'Resulted',
 3, 3, 11),

(3, 'TROP', 'Troponin test', CURRENT_DATE,
 NULL, NULL, NULL, NULL, 'Ordered',
 4, 2, NULL),

(4, 'GLU', 'Blood glucose test', CURRENT_DATE,
 '5.4', 'mmol/L', '3.9-5.5', CURRENT_DATE, 'Resulted',
 5, 3, 11);

-- ============================================================
-- 15. MEDICAL AID
-- ============================================================

INSERT INTO "Medical_Aid"
("MedicalAidID", "SchemeName", "SchemeType", "MemberNumber",
 "CoverageLimit", "EffectiveDate", "ExpiryDate", "PatientID")
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Discovery Health', 'Comprehensive', 'DH-100001', 50000.00, '2026-01-01', '2026-12-31', 1),
(2, 'Bonitas', 'Standard', 'BN-200002', 30000.00, '2026-01-01', '2026-12-31', 3),
(3, 'Momentum Health', 'Hospital Plan', 'MH-300003', 40000.00, '2025-01-01', '2025-12-31', 5),
(4, 'Medihelp', 'Comprehensive', 'MHLP-400004', 60000.00, '2026-02-01', '2027-01-31', 7);

-- ============================================================
-- 16. BILLING
-- OutstandingBalance is generated automatically.
-- AdmissionID is UNIQUE to enforce one bill per admission.
-- ============================================================

INSERT INTO "Billing"
("BillingID", "BillDate", "TotalAmount", "AmountPaid", "PaymentStatus",
 "AdmissionID", "PatientID", "MedicalAidID")
OVERRIDING SYSTEM VALUE
VALUES
(1, CURRENT_DATE - INTERVAL '4 days', 8500.00, 8500.00, 'Paid', 1, 5, 3),
(2, CURRENT_DATE - INTERVAL '2 days', 45000.00, 15000.00, 'Partial Payment', 2, 7, 4),
(3, CURRENT_DATE, 6200.00, 0.00, 'Pending', 3, 3, 2),
(4, CURRENT_DATE, 3200.00, 0.00, 'Pending', 4, 1, 1),
(5, CURRENT_DATE, 4100.00, 1000.00, 'Partial Payment', 5, 9, NULL);

-- ============================================================
-- 17. BILLING LOG
-- Manual sample entries. Trigger-generated entries will be added
-- later in 05_extra_functionality.sql.
-- ============================================================

INSERT INTO "BillingLog"
("BillingLogID", "BillingID", "TotalAmount", "AmountPaid", "OutstandingBalance", "PaymentStatus", "LogAction")
OVERRIDING SYSTEM VALUE
VALUES
(1, 1, 8500.00, 8500.00, 0.00, 'Paid', 'SAMPLE INSERT'),
(2, 2, 45000.00, 15000.00, 30000.00, 'Partial Payment', 'SAMPLE INSERT'),
(3, 3, 6200.00, 0.00, 6200.00, 'Pending', 'SAMPLE INSERT');

-- ============================================================
-- 18. AUDIT LOG
-- ============================================================

INSERT INTO "AuditLog"
("AuditID", "UserID", "Action", "TableName", "RecordID", "Description")
OVERRIDING SYSTEM VALUE
VALUES
(1, 8, 'CREATE', 'Patient', '1', 'Receptionist registered patient Mpho Ndlovu.'),
(2, 2, 'CREATE', 'Diagnosis', '2', 'Doctor recorded angina diagnosis.'),
(3, 2, 'CREATE', 'Prescription', '2', 'Doctor issued prescription for cardiac patient.'),
(4, 11, 'UPDATE', 'Laboratory_Test', '1', 'Lab technician recorded FBC result.'),
(5, 10, 'CREATE', 'Billing', '2', 'Billing officer created partial payment bill.');

-- ============================================================
-- RESET IDENTITY SEQUENCES AFTER EXPLICIT IDs
-- Ensures future inserts continue from the correct next ID.
-- ============================================================

SELECT setval(pg_get_serial_sequence('"Department"', 'DepartmentID'), COALESCE(MAX("DepartmentID"), 1), TRUE) FROM "Department";
SELECT setval(pg_get_serial_sequence('"Staff"', 'UserID'), COALESCE(MAX("UserID"), 1), TRUE) FROM "Staff";
SELECT setval(pg_get_serial_sequence('"Ward"', 'WardID'), COALESCE(MAX("WardID"), 1), TRUE) FROM "Ward";
SELECT setval(pg_get_serial_sequence('"Patient"', 'PatientID'), COALESCE(MAX("PatientID"), 1), TRUE) FROM "Patient";
SELECT setval(pg_get_serial_sequence('"Appointment"', 'AppointmentID'), COALESCE(MAX("AppointmentID"), 1), TRUE) FROM "Appointment";
SELECT setval(pg_get_serial_sequence('"Admission"', 'AdmissionID'), COALESCE(MAX("AdmissionID"), 1), TRUE) FROM "Admission";
SELECT setval(pg_get_serial_sequence('"Diagnosis"', 'DiagnosisID'), COALESCE(MAX("DiagnosisID"), 1), TRUE) FROM "Diagnosis";
SELECT setval(pg_get_serial_sequence('"Prescription"', 'PrescriptionID'), COALESCE(MAX("PrescriptionID"), 1), TRUE) FROM "Prescription";
SELECT setval(pg_get_serial_sequence('"Medication"', 'MedicationID'), COALESCE(MAX("MedicationID"), 1), TRUE) FROM "Medication";
SELECT setval(pg_get_serial_sequence('"Laboratory_Test"', 'TestID'), COALESCE(MAX("TestID"), 1), TRUE) FROM "Laboratory_Test";
SELECT setval(pg_get_serial_sequence('"Medical_Aid"', 'MedicalAidID'), COALESCE(MAX("MedicalAidID"), 1), TRUE) FROM "Medical_Aid";
SELECT setval(pg_get_serial_sequence('"Billing"', 'BillingID'), COALESCE(MAX("BillingID"), 1), TRUE) FROM "Billing";
SELECT setval(pg_get_serial_sequence('"BillingLog"', 'BillingLogID'), COALESCE(MAX("BillingLogID"), 1), TRUE) FROM "BillingLog";
SELECT setval(pg_get_serial_sequence('"AuditLog"', 'AuditID'), COALESCE(MAX("AuditID"), 1), TRUE) FROM "AuditLog";

-- ============================================================
-- QUICK VERIFICATION COUNTS
-- ============================================================

SELECT 'Department' AS table_name, COUNT(*) AS record_count FROM "Department"
UNION ALL SELECT 'Staff', COUNT(*) FROM "Staff"
UNION ALL SELECT 'Doctor', COUNT(*) FROM "Doctor"
UNION ALL SELECT 'Nurse', COUNT(*) FROM "Nurse"
UNION ALL SELECT 'Receptionist', COUNT(*) FROM "Receptionist"
UNION ALL SELECT 'LabTechnician', COUNT(*) FROM "LabTechnician"
UNION ALL SELECT 'Ward', COUNT(*) FROM "Ward"
UNION ALL SELECT 'Patient', COUNT(*) FROM "Patient"
UNION ALL SELECT 'Allergy', COUNT(*) FROM "Allergy"
UNION ALL SELECT 'Appointment', COUNT(*) FROM "Appointment"
UNION ALL SELECT 'Admission', COUNT(*) FROM "Admission"
UNION ALL SELECT 'Diagnosis', COUNT(*) FROM "Diagnosis"
UNION ALL SELECT 'Prescription', COUNT(*) FROM "Prescription"
UNION ALL SELECT 'Medication', COUNT(*) FROM "Medication"
UNION ALL SELECT 'Prescription_Medication', COUNT(*) FROM "Prescription_Medication"
UNION ALL SELECT 'Laboratory_Test', COUNT(*) FROM "Laboratory_Test"
UNION ALL SELECT 'Medical_Aid', COUNT(*) FROM "Medical_Aid"
UNION ALL SELECT 'Billing', COUNT(*) FROM "Billing"
UNION ALL SELECT 'BillingLog', COUNT(*) FROM "BillingLog"
UNION ALL SELECT 'AuditLog', COUNT(*) FROM "AuditLog"
ORDER BY table_name;

-- ============================================================
-- End of 03_sample_data.sql
-- ============================================================
