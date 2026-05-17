from django.shortcuts import render, redirect
from common.decorators import login_required_raw, role_required
from common.sql import rows, execute

@login_required_raw
@role_required('Admin','BillingOfficer')
def billing_list(request):
    bills=rows('''
        SELECT b."BillingID", b."BillDate", b."TotalAmount", b."AmountPaid", b."OutstandingBalance", b."PaymentStatus",
               CONCAT(p."FirstName", ' ', p."LastName") AS patient, ma."SchemeName", ma."MemberNumber"
        FROM "Billing" b
        JOIN "Patient" p ON b."PatientID"=p."PatientID"
        LEFT JOIN "Medical_Aid" ma ON b."MedicalAidID"=ma."MedicalAidID"
        ORDER BY b."BillDate" DESC, b."BillingID" DESC;
    ''')
    logs=rows('SELECT * FROM "BillingLog" ORDER BY "CreatedAt" DESC LIMIT 20')
    return render(request,'billing/list.html',{'bills':bills,'logs':logs})

@login_required_raw
@role_required('Admin','BillingOfficer')
def record_payment(request, billing_id):
    if request.method=='POST':
        amount=request.POST.get('amount') or '0'
        execute('''
            UPDATE "Billing"
            SET "AmountPaid" = LEAST("TotalAmount", "AmountPaid" + %s::numeric),
                "PaymentStatus" = CASE
                    WHEN LEAST("TotalAmount", "AmountPaid" + %s::numeric) = "TotalAmount" THEN 'Paid'
                    WHEN LEAST("TotalAmount", "AmountPaid" + %s::numeric) > 0 THEN 'Partial Payment'
                    ELSE "PaymentStatus" END
            WHERE "BillingID"=%s
        ''',[amount, amount, amount, billing_id])
    return redirect('billing_list')
