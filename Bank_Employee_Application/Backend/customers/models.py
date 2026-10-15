from django.db import models


class Customer(models.Model):
    customer_id = models.CharField(max_length=40, primary_key=True)
    full_name = models.CharField(max_length=200)
    date_of_birth = models.DateField()
    email = models.EmailField(max_length=254)
    phone = models.CharField(max_length=40)
    address = models.TextField()
    account_number = models.CharField(max_length=40, unique=True)
    account_type = models.CharField(
        max_length=20,
        choices=[("Savings", "Savings"), ("Current", "Current")],
    )
    branch_name = models.CharField(max_length=150)
    branch_code = models.CharField(max_length=40)
    account_opening_date = models.DateField()
    account_balance = models.DecimalField(max_digits=16, decimal_places=2)
    account_status = models.CharField(
        max_length=20,
        choices=[("Active", "Active"), ("Inactive", "Inactive")],
    )

    class Meta:
        ordering = ["customer_id"]

    def __str__(self):
        return f"{self.customer_id} - {self.full_name}"
