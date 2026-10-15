from rest_framework import serializers

from .models import Customer


class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = [
            "customer_id",
            "full_name",
            "date_of_birth",
            "email",
            "phone",
            "address",
            "account_number",
            "account_type",
            "branch_name",
            "branch_code",
            "account_opening_date",
            "account_balance",
            "account_status",
        ]
