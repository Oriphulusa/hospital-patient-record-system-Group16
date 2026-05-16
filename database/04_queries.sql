-- ============================================================
-- CMPG 311 GROUP 16 - HPRS PHASE 3
-- 04_queries.sql
-- PostgreSQL Query Demonstration Script
-- Hospital Patient Record System (HPRS)
--
-- Purpose:
-- Covers Phase 3 Query Requirements worth 52 marks:
--   - Queries based on company information requirements
--   - Query limitations: rows and columns
--   - Sorting operations
--   - LIKE, AND, OR operators
--   - Variables and character functions
--   - Rounding/truncation
--   - Date functions
--   - Aggregate functions
--   - GROUP BY and HAVING
--   - Joins
--   - Subqueries
--
-- Run this AFTER:
--   01_create_tables.sql
--   02_indexes_views.sql
--   03_sample_data.sql
-- ============================================================

-- ============================================================
-- SECTION A: BUSINESS INFORMATION REQUIREMENT QUERIES
-- ============================================================

-- 1. Patients admitted in the last 30 days with doctor and ward.
SELECT
    a."AdmissionID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    a."AdmissionDate",
    a."AdmissionType",
    w."WardName",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName"
FROM "Admission" a
JOIN "Patient" p ON a."PatientID" = p."PatientID"
JOIN "Ward" w ON a."WardID" = w."WardID"
JOIN "Doctor" d ON a."DoctorID" = d."UserID"
JOIN "Staff" s ON d."UserID" = s."UserID"
WHERE a."AdmissionDate" >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY a."AdmissionDate" DESC;

-- 2. Unpaid or partially paid billing records with patient contact information.
SELECT
    b."BillingID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    p."Phone",
    p."Email",
    b."TotalAmount",
    b."AmountPaid",
    b."OutstandingBalance",
    b."PaymentStatus"
FROM "Billing" b
JOIN "Patient" p ON b."PatientID" = p."PatientID"
WHERE b."PaymentStatus" IN ('Pending', 'Partial Payment', 'Overdue')
ORDER BY b."OutstandingBalance" DESC;

-- 3. Appointments for a specific doctor today.
SELECT
    ap."AppointmentID",
    ap."AppointmentDate",
    ap."AppointmentTime",
    ap."Status",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    ap."Reason"
FROM "Appointment" ap
JOIN "Patient" p ON ap."PatientID" = p."PatientID"
WHERE ap."DoctorID" = 2
  AND ap."AppointmentDate" = CURRENT_DATE
ORDER BY ap."AppointmentTime";

-- 4. Prescriptions for a specific ICD-10 diagnosis code.
SELECT
    pr."PrescriptionID",
    pr."DateIssued",
    dg."ICD10Code",
    dg."Description" AS "DiagnosisDescription",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    pr."DosageInstructions"
FROM "Prescription" pr
JOIN "Diagnosis" dg ON pr."DiagnosisID" = dg."DiagnosisID"
JOIN "Admission" a ON dg."AdmissionID" = a."AdmissionID"
JOIN "Patient" p ON a."PatientID" = p."PatientID"
WHERE dg."ICD10Code" = 'I20.9';

-- 5. Lab tests ordered but not yet resulted.
SELECT
    lt."TestID",
    lt."TestCode",
    lt."TestDescription",
    lt."OrderDate",
    lt."Status",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName"
FROM "Laboratory_Test" lt
JOIN "Admission" a ON lt."AdmissionID" = a."AdmissionID"
JOIN "Patient" p ON a."PatientID" = p."PatientID"
JOIN "Staff" s ON lt."DoctorID" = s."UserID"
WHERE lt."Status" IN ('Ordered', 'In Progress')
ORDER BY lt."OrderDate";

-- 6. Current ward occupancy.
SELECT * FROM "vw_WardOccupancy" ORDER BY "WardName";

-- 7. Patients with critical or severe allergies.
SELECT
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    al."AllergyName",
    al."Severity",
    al."DateRecorded"
FROM "Allergy" al
JOIN "Patient" p ON al."PatientID" = p."PatientID"
WHERE al."Severity" IN ('Critical', 'Severe')
ORDER BY al."Severity", p."LastName";

-- ============================================================
-- SECTION B: QUERY LIMITATIONS - ROWS AND COLUMNS
-- ============================================================

-- 8. Top 5 most recently registered patients.
SELECT
    "PatientID",
    CONCAT("FirstName", ' ', "LastName") AS "FullName",
    "CreatedAt"
FROM "Patient"
ORDER BY "CreatedAt" DESC
LIMIT 5;

-- 9. Only selected columns: PatientID, FullName, Phone.
SELECT
    "PatientID",
    CONCAT("FirstName", ' ', "LastName") AS "FullName",
    "Phone"
FROM "Patient";

-- 10. Show only first 3 outstanding bills.
SELECT
    "BillingID",
    "PatientFullName",
    "OutstandingBalance",
    "PaymentStatus"
FROM "vw_OutstandingBilling"
LIMIT 3;

-- ============================================================
-- SECTION C: SORTING OPERATIONS
-- ============================================================

-- 11. Appointments sorted by date descending and time ascending.
SELECT
    "AppointmentID",
    "AppointmentDate",
    "AppointmentTime",
    "Status",
    "PatientID",
    "DoctorID"
FROM "Appointment"
ORDER BY "AppointmentDate" DESC, "AppointmentTime" ASC;

-- 12. Medications ordered alphabetically.
SELECT
    "MedicationID",
    "MedicationName",
    "DosageForm",
    "Strength",
    "StockQuantity"
FROM "Medication"
ORDER BY "MedicationName" ASC;

-- 13. Bills ordered by outstanding balance descending.
SELECT
    "BillingID",
    "TotalAmount",
    "AmountPaid",
    "OutstandingBalance",
    "PaymentStatus"
FROM "Billing"
ORDER BY "OutstandingBalance" DESC;

-- ============================================================
-- SECTION D: LIKE, AND, OR OPERATORS
-- ============================================================

-- 14. Patients whose last name starts with N.
SELECT
    "PatientID",
    CONCAT("FirstName", ' ', "LastName") AS "FullName",
    "Phone",
    "Province"
FROM "Patient"
WHERE "LastName" LIKE 'N%';

-- 15. Scheduled appointments for a specific doctor.
SELECT
    "AppointmentID",
    "AppointmentDate",
    "AppointmentTime",
    "Status",
    "DoctorID"
FROM "Appointment"
WHERE "DoctorID" = 3
  AND "Status" = 'Scheduled';

-- 16. Patients from Gauteng OR Western Cape.
SELECT
    "PatientID",
    CONCAT("FirstName", ' ', "LastName") AS "FullName",
    "City",
    "Province"
FROM "Patient"
WHERE "Province" = 'Gauteng'
   OR "Province" = 'Western Cape'
ORDER BY "Province", "City";

-- 17. Medication search using LIKE.
SELECT
    "MedicationID",
    "MedicationName",
    "Category",
    "StockQuantity"
FROM "Medication"
WHERE LOWER("MedicationName") LIKE LOWER('%para%')
   OR LOWER("Category") LIKE LOWER('%anti%');

-- ============================================================
-- SECTION E: VARIABLES AND CHARACTER FUNCTIONS
-- PostgreSQL variables are demonstrated using a CTE.
-- ============================================================

-- 18. CTE variable example: selected doctor ID.
WITH selected_doctor AS (
    SELECT 2::INTEGER AS doctor_id
)
SELECT
    ap."AppointmentID",
    ap."AppointmentDate",
    ap."AppointmentTime",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName"
FROM "Appointment" ap
JOIN "Patient" p ON ap."PatientID" = p."PatientID"
JOIN selected_doctor sd ON ap."DoctorID" = sd.doctor_id;

-- 19. Full name using CONCAT.
SELECT
    "PatientID",
    CONCAT("FirstName", ' ', "LastName") AS "FullName"
FROM "Patient";

-- 20. Medical aid scheme names in uppercase.
SELECT
    "MedicalAidID",
    UPPER("SchemeName") AS "SchemeNameUppercase",
    "MemberNumber"
FROM "Medical_Aid";

-- 21. Lowercase emails using LOWER.
SELECT
    "PatientID",
    LOWER("Email") AS "LowercaseEmail"
FROM "Patient"
WHERE "Email" IS NOT NULL;

-- 22. Verify ID number length is 13.
SELECT
    "PatientID",
    "IDNumber",
    LENGTH("IDNumber") AS "IDNumberLength",
    CASE
        WHEN LENGTH("IDNumber") = 13 THEN 'Valid Length'
        ELSE 'Invalid Length'
    END AS "ValidationResult"
FROM "Patient"
WHERE "IDNumber" IS NOT NULL;

-- 23. Extract date portion from a South African ID number.
SELECT
    "PatientID",
    "IDNumber",
    SUBSTRING("IDNumber" FROM 1 FOR 6) AS "IDBirthDatePart"
FROM "Patient"
WHERE "IDNumber" IS NOT NULL;

-- ============================================================
-- SECTION F: ROUNDING AND TRUNCATION
-- ============================================================

-- 24. Monthly instalment using ROUND(TotalAmount / 12, 2).
SELECT
    "BillingID",
    "TotalAmount",
    ROUND(("TotalAmount" / 12), 2) AS "MonthlyInstalment"
FROM "Billing";

-- 25. Coverage limits rounded to whole numbers.
SELECT
    "MedicalAidID",
    "SchemeName",
    ROUND("CoverageLimit", 0) AS "RoundedCoverageLimit"
FROM "Medical_Aid";

-- 26. Average billing rounded to 2 decimals.
SELECT
    ROUND(AVG("TotalAmount"), 2) AS "AverageBillingAmount"
FROM "Billing";

-- 27. Truncate billing amount to nearest integer.
SELECT
    "BillingID",
    "TotalAmount",
    TRUNC("TotalAmount", 0) AS "TruncatedTotalAmount"
FROM "Billing";

-- ============================================================
-- SECTION G: DATE FUNCTIONS
-- ============================================================

-- 28. Age calculated from DateOfBirth.
SELECT
    "PatientID",
    CONCAT("FirstName", ' ', "LastName") AS "FullName",
    "DateOfBirth",
    DATE_PART('year', AGE(CURRENT_DATE, "DateOfBirth"))::INT AS "Age"
FROM "Patient";

-- 29. Length of stay using discharge date minus admission date.
SELECT
    "AdmissionID",
    "AdmissionDate",
    "ActualDischargeDate",
    COALESCE("ActualDischargeDate", CURRENT_DATE) - "AdmissionDate" AS "LengthOfStayDays"
FROM "Admission";

-- 30. Admissions longer than 3 days.
SELECT
    "AdmissionID",
    "PatientID",
    "AdmissionDate",
    COALESCE("ActualDischargeDate", CURRENT_DATE) - "AdmissionDate" AS "LengthOfStayDays"
FROM "Admission"
WHERE COALESCE("ActualDischargeDate", CURRENT_DATE) - "AdmissionDate" > 3;

-- 31. Appointments in the current month.
SELECT
    "AppointmentID",
    "AppointmentDate",
    "AppointmentTime",
    "Status"
FROM "Appointment"
WHERE DATE_TRUNC('month', "AppointmentDate") = DATE_TRUNC('month', CURRENT_DATE);

-- 32. Format appointment dates for reports.
SELECT
    "AppointmentID",
    TO_CHAR("AppointmentDate", 'DD Mon YYYY') AS "FormattedDate",
    TO_CHAR("AppointmentTime", 'HH24:MI') AS "FormattedTime",
    "Status"
FROM "Appointment";

-- ============================================================
-- SECTION H: AGGREGATE FUNCTIONS
-- ============================================================

-- 33. Total number of patients.
SELECT COUNT(*) AS "TotalPatients" FROM "Patient";

-- 34. Total billing amount.
SELECT SUM("TotalAmount") AS "TotalBillingAmount" FROM "Billing";

-- 35. Average billing amount.
SELECT AVG("TotalAmount") AS "AverageBillingAmount" FROM "Billing";

-- 36. Minimum and maximum coverage limit.
SELECT
    MIN("CoverageLimit") AS "MinimumCoverageLimit",
    MAX("CoverageLimit") AS "MaximumCoverageLimit"
FROM "Medical_Aid";

-- 37. Count active admissions.
SELECT COUNT(*) AS "ActiveAdmissions"
FROM "Admission"
WHERE "ActualDischargeDate" IS NULL;

-- 38. Count lab tests by status.
SELECT
    "Status",
    COUNT(*) AS "TestCount"
FROM "Laboratory_Test"
GROUP BY "Status"
ORDER BY "Status";

-- ============================================================
-- SECTION I: GROUP BY AND HAVING
-- ============================================================

-- 39. Appointments per doctor with HAVING count greater than 1.
SELECT
    ap."DoctorID",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName",
    COUNT(*) AS "AppointmentCount"
FROM "Appointment" ap
JOIN "Staff" s ON ap."DoctorID" = s."UserID"
GROUP BY ap."DoctorID", s."FirstName", s."LastName"
HAVING COUNT(*) > 1
ORDER BY "AppointmentCount" DESC;

-- 40. Total billing per patient with HAVING sum greater than 5000.
SELECT
    b."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    SUM(b."TotalAmount") AS "TotalBilling"
FROM "Billing" b
JOIN "Patient" p ON b."PatientID" = p."PatientID"
GROUP BY b."PatientID", p."FirstName", p."LastName"
HAVING SUM(b."TotalAmount") > 5000
ORDER BY "TotalBilling" DESC;

-- 41. Admissions per ward.
SELECT
    w."WardID",
    w."WardName",
    COUNT(a."AdmissionID") AS "AdmissionCount"
FROM "Ward" w
LEFT JOIN "Admission" a ON w."WardID" = a."WardID"
GROUP BY w."WardID", w."WardName"
ORDER BY "AdmissionCount" DESC;

-- 42. Diagnoses grouped by ICD10Code.
SELECT
    "ICD10Code",
    COUNT(*) AS "DiagnosisCount"
FROM "Diagnosis"
GROUP BY "ICD10Code"
ORDER BY "DiagnosisCount" DESC;

-- ============================================================
-- SECTION J: JOINS
-- ============================================================

-- 43. Patient appointment doctor join.
SELECT
    ap."AppointmentID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName",
    ap."AppointmentDate",
    ap."AppointmentTime",
    ap."Status"
FROM "Appointment" ap
JOIN "Patient" p ON ap."PatientID" = p."PatientID"
JOIN "Staff" s ON ap."DoctorID" = s."UserID"
ORDER BY ap."AppointmentDate", ap."AppointmentTime";

-- 44. Patients with and without billing using LEFT JOIN.
SELECT
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    b."BillingID",
    b."PaymentStatus",
    b."OutstandingBalance"
FROM "Patient" p
LEFT JOIN "Billing" b ON p."PatientID" = b."PatientID"
ORDER BY p."PatientID";

-- 45. Admission details with patient, doctor, ward, and diagnosis.
SELECT
    a."AdmissionID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName",
    w."WardName",
    dg."ICD10Code",
    dg."Description" AS "DiagnosisDescription",
    a."AdmissionDate"
FROM "Admission" a
JOIN "Patient" p ON a."PatientID" = p."PatientID"
JOIN "Staff" s ON a."DoctorID" = s."UserID"
JOIN "Ward" w ON a."WardID" = w."WardID"
LEFT JOIN "Diagnosis" dg ON a."AdmissionID" = dg."AdmissionID"
ORDER BY a."AdmissionID";

-- 46. Prescription medication join.
SELECT
    pr."PrescriptionID",
    m."MedicationName",
    m."Strength",
    pm."Quantity",
    pm."Frequency",
    pm."Duration"
FROM "Prescription" pr
JOIN "Prescription_Medication" pm ON pr."PrescriptionID" = pm."PrescriptionID"
JOIN "Medication" m ON pm."MedicationID" = m."MedicationID"
ORDER BY pr."PrescriptionID";

-- 47. Lab test join with patient, admission, doctor, and lab technician.
SELECT
    lt."TestID",
    lt."TestCode",
    lt."Status",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    CONCAT(ds."FirstName", ' ', ds."LastName") AS "DoctorFullName",
    CONCAT(ls."FirstName", ' ', ls."LastName") AS "LabTechnicianFullName"
FROM "Laboratory_Test" lt
JOIN "Admission" a ON lt."AdmissionID" = a."AdmissionID"
JOIN "Patient" p ON a."PatientID" = p."PatientID"
JOIN "Staff" ds ON lt."DoctorID" = ds."UserID"
LEFT JOIN "Staff" ls ON lt."LabTechnicianID" = ls."UserID";

-- 48. Medical aid and billing join.
SELECT
    b."BillingID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    ma."SchemeName",
    ma."CoverageLimit",
    b."TotalAmount",
    b."OutstandingBalance"
FROM "Billing" b
JOIN "Patient" p ON b."PatientID" = p."PatientID"
LEFT JOIN "Medical_Aid" ma ON b."MedicalAidID" = ma."MedicalAidID";

-- ============================================================
-- SECTION K: SUBQUERIES
-- ============================================================

-- 49. Patients never admitted.
SELECT
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName"
FROM "Patient" p
WHERE p."PatientID" NOT IN (
    SELECT a."PatientID"
    FROM "Admission" a
);

-- 50. Doctor who issued the most prescriptions.
SELECT
    s."UserID" AS "DoctorID",
    CONCAT(s."FirstName", ' ', s."LastName") AS "DoctorFullName",
    COUNT(pr."PrescriptionID") AS "PrescriptionCount"
FROM "Staff" s
JOIN "Doctor" d ON s."UserID" = d."UserID"
JOIN "Prescription" pr ON d."UserID" = pr."DoctorID"
GROUP BY s."UserID", s."FirstName", s."LastName"
HAVING COUNT(pr."PrescriptionID") = (
    SELECT MAX(prescription_total)
    FROM (
        SELECT COUNT(*) AS prescription_total
        FROM "Prescription"
        GROUP BY "DoctorID"
    ) totals
);

-- 51. Patients with billing above average billing.
SELECT
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
    b."TotalAmount"
FROM "Billing" b
JOIN "Patient" p ON b."PatientID" = p."PatientID"
WHERE b."TotalAmount" > (
    SELECT AVG("TotalAmount")
    FROM "Billing"
)
ORDER BY b."TotalAmount" DESC;

-- 52. Medications below average stock level.
SELECT
    "MedicationID",
    "MedicationName",
    "StockQuantity"
FROM "Medication"
WHERE "StockQuantity" < (
    SELECT AVG("StockQuantity")
    FROM "Medication"
)
ORDER BY "StockQuantity";

-- 53. Patients with active medical aid.
SELECT
    p."PatientID",
    CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName"
FROM "Patient" p
WHERE EXISTS (
    SELECT 1
    FROM "Medical_Aid" ma
    WHERE ma."PatientID" = p."PatientID"
      AND CURRENT_DATE BETWEEN ma."EffectiveDate" AND ma."ExpiryDate"
);

-- 54. Admissions that do not yet have billing records.
SELECT
    a."AdmissionID",
    a."PatientID",
    a."AdmissionDate"
FROM "Admission" a
WHERE NOT EXISTS (
    SELECT 1
    FROM "Billing" b
    WHERE b."AdmissionID" = a."AdmissionID"
);

-- ============================================================
-- SECTION L: VIEW-BASED DEMONSTRATION QUERIES
-- ============================================================

-- 55. Patient summary view.
SELECT *
FROM "vw_PatientSummary"
ORDER BY "FullName";

-- 56. Doctor workload view.
SELECT *
FROM "vw_DoctorWorkload"
ORDER BY "AppointmentCount" DESC;

-- 57. Admission billing summary view.
SELECT *
FROM "vw_AdmissionBillingSummary"
ORDER BY "AdmissionDate" DESC;

-- 58. Outstanding billing view.
SELECT *
FROM "vw_OutstandingBilling"
ORDER BY "OutstandingBalance" DESC;

-- 59. Active medical aid view.
SELECT *
FROM "vw_ActiveMedicalAid"
ORDER BY "PatientFullName";

-- 60. Ward occupancy view.
SELECT *
FROM "vw_WardOccupancy"
ORDER BY "WardName";

-- ============================================================
-- End of 04_queries.sql
-- ============================================================
