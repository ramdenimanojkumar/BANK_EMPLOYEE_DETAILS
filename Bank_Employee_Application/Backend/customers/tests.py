from rest_framework.test import APITestCase

from .models import Customer


class CustomerApiTests(APITestCase):
    customer_data = {
        "customer_id": "CUST-5001",
        "full_name": "Jane Doe",
        "date_of_birth": "1992-08-20",
        "email": "jane.doe@example.com",
        "phone": "+1 (555) 987-6543",
        "address": "100 Financial Way, New York, NY 10001",
        "account_number": "100982347120",
        "account_type": "Savings",
        "branch_name": "Downtown Financial Center",
        "branch_code": "APX-NYC-01",
        "account_opening_date": "2023-05-10",
        "account_balance": "12500.75",
        "account_status": "Active",
    }

    def test_create_then_list_and_retrieve_customer_by_id(self):
        create_response = self.client.post(
            "/api/customers/",
            self.customer_data,
            format="json",
        )

        self.assertEqual(create_response.status_code, 201)
        self.assertEqual(create_response.data["customer_id"], "CUST-5001")
        self.assertEqual(Customer.objects.count(), 1)

        list_response = self.client.get("/api/customers/")
        self.assertEqual(list_response.status_code, 200)
        self.assertEqual(len(list_response.data), 1)

        detail_response = self.client.get("/api/customers/CUST-5001/")
        self.assertEqual(detail_response.status_code, 200)
        self.assertEqual(detail_response.data["full_name"], "Jane Doe")

    def test_unknown_customer_id_returns_not_found(self):
        response = self.client.get("/api/customers/MISSING/")

        self.assertEqual(response.status_code, 404)

    def test_duplicate_account_number_is_rejected(self):
        Customer.objects.create(
            **{
                **self.customer_data,
                "account_balance": "12500.75",
            }
        )
        duplicate = {
            **self.customer_data,
            "customer_id": "CUST-5002",
        }

        response = self.client.post("/api/customers/", duplicate, format="json")

        self.assertEqual(response.status_code, 400)
        self.assertIn("account_number", response.data)

    def test_health_endpoint_confirms_database_connection(self):
        response = self.client.get("/api/health/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["database"], "connected")
