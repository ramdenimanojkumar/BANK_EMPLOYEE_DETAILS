// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/models/customer.dart';
import '../lib/services/customer_service.dart';

void main() {
  group('Customer Model Tests', () {
    test(
      'toJson and fromJson correctly serialize and deserialize all 13 customer attributes',
      () {
        final sample = Customer(
          customerId: 'CUST-5001',
          fullName: 'Jane Doe',
          dateOfBirth: DateTime(1992, 8, 20),
          email: 'jane.doe@example.com',
          phone: '+1 (555) 987-6543',
          address: '100 Financial Way, New York, NY 10001',
          accountNumber: '100982347120',
          accountType: 'Savings',
          branchName: 'Downtown Financial Center',
          branchCode: 'APX-NYC-01',
          accountOpeningDate: DateTime(2023, 5, 10),
          accountBalance: 12500.75,
          accountStatus: 'Active',
        );

        final json = sample.toJson();
        expect(json['customer_id'], 'CUST-5001');
        expect(json['full_name'], 'Jane Doe');
        expect(json['date_of_birth'], '1992-08-20');
        expect(json['email'], 'jane.doe@example.com');
        expect(json['phone'], '+1 (555) 987-6543');
        expect(json['address'], '100 Financial Way, New York, NY 10001');
        expect(json['account_number'], '100982347120');
        expect(json['account_type'], 'Savings');
        expect(json['branch_name'], 'Downtown Financial Center');
        expect(json['branch_code'], 'APX-NYC-01');
        expect(json['account_opening_date'], '2023-05-10');
        expect(json['account_balance'], 12500.75);
        expect(json['account_status'], 'Active');

        final reconstructed = Customer.fromJson(json);
        expect(reconstructed.customerId, sample.customerId);
        expect(reconstructed.fullName, sample.fullName);
        expect(reconstructed.dateOfBirth.year, 1992);
        expect(reconstructed.email, sample.email);
        expect(reconstructed.phone, sample.phone);
        expect(reconstructed.address, sample.address);
        expect(reconstructed.accountNumber, sample.accountNumber);
        expect(reconstructed.accountType, sample.accountType);
        expect(reconstructed.branchName, sample.branchName);
        expect(reconstructed.branchCode, sample.branchCode);
        expect(reconstructed.accountOpeningDate.year, 2023);
        expect(reconstructed.accountBalance, sample.accountBalance);
        expect(reconstructed.accountStatus, sample.accountStatus);
      },
    );

    test(
      'Customer.copyWith returns updated copy while maintaining untouched fields',
      () {
        final initial = Customer(
          customerId: 'CUST-1001',
          fullName: 'Initial Name',
          dateOfBirth: DateTime(1990, 1, 1),
          email: 'init@bank.com',
          phone: '1234567890',
          address: 'Initial Address',
          accountNumber: '11112222',
          accountType: 'Savings',
          branchName: 'Main Branch',
          branchCode: 'MB-01',
          accountOpeningDate: DateTime(2022, 1, 1),
          accountBalance: 1000.0,
          accountStatus: 'Active',
        );

        final updated = initial.copyWith(
          fullName: 'Updated Name',
          accountBalance: 2500.0,
          accountStatus: 'Inactive',
        );

        expect(updated.customerId, 'CUST-1001');
        expect(updated.fullName, 'Updated Name');
        expect(updated.accountBalance, 2500.0);
        expect(updated.accountStatus, 'Inactive');
        expect(updated.accountNumber, '11112222');
      },
    );
  });

  group('CustomerService API integration', () {
    final sample = Customer(
      customerId: 'CUST-5001',
      fullName: 'Jane Doe',
      dateOfBirth: DateTime(1992, 8, 20),
      email: 'jane.doe@example.com',
      phone: '+1 (555) 987-6543',
      address: '100 Financial Way, New York, NY 10001',
      accountNumber: '100982347120',
      accountType: 'Savings',
      branchName: 'Downtown Financial Center',
      branchCode: 'APX-NYC-01',
      accountOpeningDate: DateTime(2023, 5, 10),
      accountBalance: 12500.75,
      accountStatus: 'Active',
    );

    test('creates a customer using the existing JSON field names', () async {
      final service = CustomerService.testing(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/customers/');
          expect(jsonDecode(request.body), sample.toJson());
          return http.Response(jsonEncode(sample.toJson()), 201);
        }),
      );

      final created = await service.createCustomer(sample);
      expect(created.customerId, sample.customerId);
      expect(created.accountBalance, sample.accountBalance);
    });

    test('retrieves a customer by its ID', () async {
      final service = CustomerService.testing(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/customers/CUST-5001/');
          return http.Response(jsonEncode(sample.toJson()), 200);
        }),
      );

      final customer = await service.getCustomerById('cust-5001');
      expect(customer?.fullName, sample.fullName);
    });

    test('returns null when the requested ID does not exist', () async {
      final service = CustomerService.testing(
        MockClient((_) async => http.Response('{"detail":"Not found."}', 404)),
      );

      expect(await service.getCustomerById('MISSING'), isNull);
    });

    test('lists persisted customers', () async {
      final service = CustomerService.testing(
        MockClient((request) async {
          expect(request.url.path, '/api/customers/');
          return http.Response(jsonEncode([sample.toJson()]), 200);
        }),
      );

      final customers = await service.getAllCustomers();
      expect(customers, hasLength(1));
      expect(customers.single.customerId, sample.customerId);
    });

    test('surfaces server validation errors', () async {
      final service = CustomerService.testing(
        MockClient(
          (_) async =>
              http.Response('{"customer_id":["Already exists."]}', 400),
        ),
      );

      expect(
        () => service.createCustomer(sample),
        throwsA(isA<CustomerApiException>()),
      );
    });
  });
}
