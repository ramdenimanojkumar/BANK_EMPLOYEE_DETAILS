from django.contrib import admin

from .models import Customer


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ("customer_id", "full_name", "account_number", "account_type", "account_status")
    search_fields = ("customer_id", "full_name", "account_number", "email")
    list_filter = ("account_type", "account_status")
