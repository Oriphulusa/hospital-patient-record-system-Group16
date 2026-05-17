-- ============================================================
-- CMPG 311 GROUP 16 - HPRS PHASE 3
-- 05_extra_functionality.sql
-- PostgreSQL Extra Functionality Script
-- Hospital Patient Record System (HPRS)
--
-- Purpose:
-- Covers Phase 3 Video Demonstration / Extra Functionality:
--   - Trigger for BillingLog
--   - Trigger for AuditLog
--   - Stored functions for patient record retrieval
--   - Medical aid active verification
--   - Billing payment update function
--
-- Run this AFTER:
--   01_create_tables.sql
--   02_indexes_views.sql
--   03_sample_data.sql
--   04_queries.sql
--
-- PostgreSQL only.
-- ============================================================

-- ============================================================
-- SECTION A: BILLING LOG TRIGGER
-- Automatically records billing changes in BillingLog.
-- ============================================================

DROP TRIGGER IF EXISTS "trg_billing_after_insert_update" ON "Billing";
DROP FUNCTION IF EXISTS "fn_log_billing_change"();

CREATE OR REPLACE FUNCTION "fn_log_billing_change"()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "BillingLog"
    (
        "BillingID",
        "TotalAmount",
        "AmountPaid",
        "OutstandingBalance",
        "PaymentStatus",
        "LogAction",
        "CreatedAt"
    )
    VALUES
    (
        NEW."BillingID",
        NEW."TotalAmount",
        NEW."AmountPaid",
        NEW."OutstandingBalance",
        NEW."PaymentStatus",
        TG_OP,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_billing_after_insert_update"
AFTER INSERT OR UPDATE ON "Billing"
FOR EACH ROW
EXECUTE FUNCTION "fn_log_billing_change"();

-- ============================================================
-- SECTION B: AUDIT LOG TRIGGERS
-- Automatically records important patient, diagnosis,
-- prescription, laboratory, and billing actions.
-- ============================================================

DROP TRIGGER IF EXISTS "trg_audit_patient_insert" ON "Patient";
DROP TRIGGER IF EXISTS "trg_audit_diagnosis_insert" ON "Diagnosis";
DROP TRIGGER IF EXISTS "trg_audit_prescription_insert" ON "Prescription";
DROP TRIGGER IF EXISTS "trg_audit_lab_update" ON "Laboratory_Test";
DROP TRIGGER IF EXISTS "trg_audit_billing_insert" ON "Billing";
DROP FUNCTION IF EXISTS "fn_audit_patient_insert"();
DROP FUNCTION IF EXISTS "fn_audit_diagnosis_insert"();
DROP FUNCTION IF EXISTS "fn_audit_prescription_insert"();
DROP FUNCTION IF EXISTS "fn_audit_lab_update"();
DROP FUNCTION IF EXISTS "fn_audit_billing_insert"();

CREATE OR REPLACE FUNCTION "fn_audit_patient_insert"()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AuditLog"
    (
        "UserID",
        "Action",
        "TableName",
        "RecordID",
        "Description",
        "Timestamp"
    )
    VALUES
    (
        NULL,
        'CREATE',
        'Patient',
        NEW."PatientID"::TEXT,
        CONCAT('New patient registered: ', NEW."FirstName", ' ', NEW."LastName"),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_audit_patient_insert"
AFTER INSERT ON "Patient"
FOR EACH ROW
EXECUTE FUNCTION "fn_audit_patient_insert"();

CREATE OR REPLACE FUNCTION "fn_audit_diagnosis_insert"()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AuditLog"
    (
        "UserID",
        "Action",
        "TableName",
        "RecordID",
        "Description",
        "Timestamp"
    )
    VALUES
    (
        NEW."DoctorID",
        'CREATE',
        'Diagnosis',
        NEW."DiagnosisID"::TEXT,
        CONCAT('Diagnosis created with ICD-10 code ', NEW."ICD10Code"),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_audit_diagnosis_insert"
AFTER INSERT ON "Diagnosis"
FOR EACH ROW
EXECUTE FUNCTION "fn_audit_diagnosis_insert"();

CREATE OR REPLACE FUNCTION "fn_audit_prescription_insert"()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AuditLog"
    (
        "UserID",
        "Action",
        "TableName",
        "RecordID",
        "Description",
        "Timestamp"
    )
    VALUES
    (
        NEW."DoctorID",
        'CREATE',
        'Prescription',
        NEW."PrescriptionID"::TEXT,
        CONCAT('Prescription issued for diagnosis ', NEW."DiagnosisID"),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_audit_prescription_insert"
AFTER INSERT ON "Prescription"
FOR EACH ROW
EXECUTE FUNCTION "fn_audit_prescription_insert"();

CREATE OR REPLACE FUNCTION "fn_audit_lab_update"()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."Status" = 'Resulted'
       AND (OLD."Status" IS DISTINCT FROM NEW."Status"
            OR OLD."ResultValue" IS DISTINCT FROM NEW."ResultValue") THEN

        INSERT INTO "AuditLog"
        (
            "UserID",
            "Action",
            "TableName",
            "RecordID",
            "Description",
            "Timestamp"
        )
        VALUES
        (
            NEW."LabTechnicianID",
            'UPDATE',
            'Laboratory_Test',
            NEW."TestID"::TEXT,
            CONCAT('Laboratory result updated for test ', NEW."TestCode"),
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_audit_lab_update"
AFTER UPDATE ON "Laboratory_Test"
FOR EACH ROW
EXECUTE FUNCTION "fn_audit_lab_update"();

CREATE OR REPLACE FUNCTION "fn_audit_billing_insert"()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "AuditLog"
    (
        "UserID",
        "Action",
        "TableName",
        "RecordID",
        "Description",
        "Timestamp"
    )
    VALUES
    (
        NULL,
        'CREATE',
        'Billing',
        NEW."BillingID"::TEXT,
        CONCAT('Billing record created for admission ', NEW."AdmissionID"),
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_audit_billing_insert"
AFTER INSERT ON "Billing"
FOR EACH ROW
EXECUTE FUNCTION "fn_audit_billing_insert"();

-- ============================================================
-- SECTION C: FUNCTION - VERIFY ACTIVE MEDICAL AID
-- Returns whether a medical aid policy is active today.
-- ============================================================

DROP FUNCTION IF EXISTS "fn_is_medical_aid_active"(INTEGER);

CREATE OR REPLACE FUNCTION "fn_is_medical_aid_active"(p_medical_aid_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    is_active BOOLEAN;
BEGIN
    SELECT
        CURRENT_DATE BETWEEN ma."EffectiveDate" AND ma."ExpiryDate"
    INTO is_active
    FROM "Medical_Aid" ma
    WHERE ma."MedicalAidID" = p_medical_aid_id;

    RETURN COALESCE(is_active, FALSE);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SECTION D: FUNCTION - PATIENT FULL RECORD
-- Returns a complete patient overview for demo purposes.
-- ============================================================

DROP FUNCTION IF EXISTS "fn_get_patient_full_record"(INTEGER);

CREATE OR REPLACE FUNCTION "fn_get_patient_full_record"(p_patient_id INTEGER)
RETURNS TABLE
(
    "PatientID" INTEGER,
    "PatientFullName" TEXT,
    "Age" INTEGER,
    "Gender" VARCHAR,
    "Phone" VARCHAR,
    "Email" VARCHAR,
    "Allergies" TEXT,
    "Admissions" BIGINT,
    "Diagnoses" BIGINT,
    "Prescriptions" BIGINT,
    "LabTests" BIGINT,
    "TotalBilling" NUMERIC,
    "OutstandingBalance" NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p."PatientID",
        CONCAT(p."FirstName", ' ', p."LastName") AS "PatientFullName",
        DATE_PART('year', AGE(CURRENT_DATE, p."DateOfBirth"))::INTEGER AS "Age",
        p."Gender",
        p."Phone",
        p."Email",
        COALESCE(STRING_AGG(DISTINCT al."AllergyName", ', '), 'None') AS "Allergies",
        COUNT(DISTINCT a."AdmissionID") AS "Admissions",
        COUNT(DISTINCT dg."DiagnosisID") AS "Diagnoses",
        COUNT(DISTINCT pr."PrescriptionID") AS "Prescriptions",
        COUNT(DISTINCT lt."TestID") AS "LabTests",
        COALESCE(SUM(DISTINCT b."TotalAmount"), 0) AS "TotalBilling",
        COALESCE(SUM(DISTINCT b."OutstandingBalance"), 0) AS "OutstandingBalance"
    FROM "Patient" p
    LEFT JOIN "Allergy" al
        ON p."PatientID" = al."PatientID"
    LEFT JOIN "Admission" a
        ON p."PatientID" = a."PatientID"
    LEFT JOIN "Diagnosis" dg
        ON a."AdmissionID" = dg."AdmissionID"
    LEFT JOIN "Prescription" pr
        ON dg."DiagnosisID" = pr."DiagnosisID"
    LEFT JOIN "Laboratory_Test" lt
        ON a."AdmissionID" = lt."AdmissionID"
    LEFT JOIN "Billing" b
        ON p."PatientID" = b."PatientID"
    WHERE p."PatientID" = p_patient_id
    GROUP BY
        p."PatientID",
        p."FirstName",
        p."LastName",
        p."DateOfBirth",
        p."Gender",
        p."Phone",
        p."Email";
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SECTION E: FUNCTION - UPDATE BILL PAYMENT
-- Updates AmountPaid and PaymentStatus safely.
-- Billing OutstandingBalance is generated automatically.
-- ============================================================

DROP FUNCTION IF EXISTS "fn_update_bill_payment"(INTEGER, NUMERIC);

CREATE OR REPLACE FUNCTION "fn_update_bill_payment"
(
    p_billing_id INTEGER,
    p_payment_amount NUMERIC
)
RETURNS TABLE
(
    "BillingID" INTEGER,
    "TotalAmount" NUMERIC,
    "AmountPaid" NUMERIC,
    "OutstandingBalance" NUMERIC,
    "PaymentStatus" VARCHAR
)
AS $$
DECLARE
    current_total NUMERIC;
    new_amount_paid NUMERIC;
BEGIN
    IF p_payment_amount <= 0 THEN
        RAISE EXCEPTION 'Payment amount must be greater than zero.';
    END IF;

    SELECT
        b."TotalAmount",
        b."AmountPaid" + p_payment_amount
    INTO
        current_total,
        new_amount_paid
    FROM "Billing" b
    WHERE b."BillingID" = p_billing_id;

    IF current_total IS NULL THEN
        RAISE EXCEPTION 'Billing record % does not exist.', p_billing_id;
    END IF;

    IF new_amount_paid > current_total THEN
        RAISE EXCEPTION 'Payment exceeds total bill amount.';
    END IF;

    UPDATE "Billing"
    SET
        "AmountPaid" = new_amount_paid,
        "PaymentStatus" =
            CASE
                WHEN new_amount_paid = current_total THEN 'Paid'
                WHEN new_amount_paid > 0 THEN 'Partial Payment'
                ELSE 'Pending'
            END
    WHERE "BillingID" = p_billing_id;

    RETURN QUERY
    SELECT
        b."BillingID",
        b."TotalAmount",
        b."AmountPaid",
        b."OutstandingBalance",
        b."PaymentStatus"
    FROM "Billing" b
    WHERE b."BillingID" = p_billing_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SECTION F: DEMONSTRATION QUERIES
-- These can be shown during the video demonstration.
-- ============================================================

-- 1. Verify medical aid active status.
SELECT
    "MedicalAidID",
    "SchemeName",
    "MemberNumber",
    "EffectiveDate",
    "ExpiryDate",
    "fn_is_medical_aid_active"("MedicalAidID") AS "IsActiveToday"
FROM "Medical_Aid"
ORDER BY "MedicalAidID";

-- 2. Show patient full record for PatientID 1.
SELECT *
FROM "fn_get_patient_full_record"(1);

-- 3. Demonstrate billing payment update.
-- This updates BillingID 3 by adding a payment of R500.
SELECT *
FROM "fn_update_bill_payment"(3, 500.00);

-- 4. Check BillingLog after payment update.
SELECT
    "BillingLogID",
    "BillingID",
    "TotalAmount",
    "AmountPaid",
    "OutstandingBalance",
    "PaymentStatus",
    "LogAction",
    "CreatedAt"
FROM "BillingLog"
ORDER BY "BillingLogID" DESC
LIMIT 5;

-- 5. Check AuditLog entries.
SELECT
    "AuditID",
    "UserID",
    "Action",
    "TableName",
    "RecordID",
    "Description",
    "Timestamp"
FROM "AuditLog"
ORDER BY "AuditID" DESC
LIMIT 10;

-- ============================================================
-- End of 05_extra_functionality.sql
-- ============================================================
