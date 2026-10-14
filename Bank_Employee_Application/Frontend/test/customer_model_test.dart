// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/customer.dart';
import '../lib/services/customer_service.dart';

void main() {
  group('Customer Model Tests', () {
    test('toJson and fromJson correctly serialize and deserialize all 13 customer attributes', () {
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
    });

    test('Customer.copyWith returns updated copy while maintaining untouched fields', () {
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
    });
  });

  group('CustomerService Stateless Architectural Compliance Tests', () {
    late CustomerService service;

    setUp(() {
      service = CustomerService();
    });

    test('getAllCustomers throws BackendNotConnectedException by default', () async {
      expect(
        () async => await service.getAllCustomers(),
        throwsA(isA<BackendNotConnectedException>()),
      );
    });

    test('getCustomerById throws BackendNotConnectedException for valid search query', () async {
      expect(
        () async => await service.getCustomerById('CUST-1001'),
        throwsA(isA<BackendNotConnectedException>()),
      );
    });

    test('checkBackendConnection returns false when backend server is offline', () async {
      final isConnected = await service.checkBackendConnection();
      expect(isConnected, isFalse);
    });
  });
}
