from django.db import models
from decimal import Decimal
from patients.models import Patient
from insurance.models import PatientInsurance

class Bill(models.Model):
    STATUS=[('unpaid','Unpaid'),('partial','Partially Paid'),('paid','Paid')]
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='bills')
    insurance = models.ForeignKey(PatientInsurance, on_delete=models.SET_NULL, null=True, blank=True)
    description = models.CharField(max_length=200, default='Hospital services')
    status = models.CharField(max_length=15, choices=STATUS, default='unpaid')
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        ordering=['-created_at']
          managed = False
        db_table = 'billing_bill'


    def subtotal(self):
        return sum((i.line_total() for i in self.items.all()), Decimal('0'))
    def insurance_coverage(self):
        if not self.insurance: return Decimal('0')
        pct = Decimal(self.insurance.effective_coverage())
        return (self.subtotal() * pct / Decimal(100)).quantize(Decimal('0.01'))
    def total_due(self):
        return (self.subtotal() - self.insurance_coverage()).quantize(Decimal('0.01'))
    def total_paid(self):
        return sum((p.amount for p in self.payments.all()), Decimal('0'))
    def balance(self):
        return (self.total_due() - self.total_paid()).quantize(Decimal('0.01'))
    def refresh_status(self):
        bal = self.balance(); paid = self.total_paid()
        if bal <= 0: self.status='paid'
        elif paid > 0: self.status='partial'
        else: self.status='unpaid'
        self.save(update_fields=['status'])

class BillItem(models.Model):
    bill = models.ForeignKey(Bill, on_delete=models.CASCADE, related_name='items')
    description = models.CharField(max_length=200)
    quantity = models.PositiveIntegerField(default=1)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    def line_total(self): return self.quantity * self.unit_price
    class Meta:
        managed = False
        db_table = 'billing_billitem'
        
class Payment(models.Model):
    METHODS=[('cash','Cash'),('card','Card'),('insurance','Insurance'),('transfer','Bank Transfer')]
    bill = models.ForeignKey(Bill, on_delete=models.CASCADE, related_name='payments')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    method = models.CharField(max_length=15, choices=METHODS, default='cash')
    paid_at = models.DateTimeField(auto_now_add=True)
    reference = models.CharField(max_length=80, blank=True)
proof_of_payment = models.FileField(upload_to='payment_proofs/', blank=True, null=True)
    verified = models.BooleanField(default=False)
    class Meta:
        managed = False
        db_table = 'billing_payment'
