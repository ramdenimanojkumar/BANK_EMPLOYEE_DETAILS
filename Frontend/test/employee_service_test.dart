import 'package:flutter_test/flutter_test.dart';
import 'package:bank_employee_details_frontend/models/employee.dart';
import 'package:bank_employee_details_frontend/services/employee_service.dart';

void main() {
  group('Employee Model Tests', () {
    test('toJson and fromJson correctly serialize and deserialize all 13 attributes', () {
      final sample = Employee(
        id: 'EMP-9001',
        fullName: 'Jane Doe',
        email: 'jane.doe@bank.com',
        phone: '+1 555-0199',
        bankName: 'Apex Global Bank',
        branchName: 'Uptown Branch',
        branchCode: 'APX-UPT-01',
        department: 'Retail Banking',
        designation: 'Assistant Branch Manager',
        dateOfJoining: DateTime(2023, 5, 20),
        employmentStatus: 'Full-Time',
        salary: 85000.0,
        address: '100 Main St, New York, NY 10001',
      );

      final json = sample.toJson();
      expect(json['id'], 'EMP-9001');
      expect(json['full_name'], 'Jane Doe');
      expect(json['email'], 'jane.doe@bank.com');
      expect(json['salary'], 85000.0);

      final reconstructed = Employee.fromJson(json);
      expect(reconstructed.id, sample.id);
      expect(reconstructed.fullName, sample.fullName);
      expect(reconstructed.email, sample.email);
      expect(reconstructed.salary, sample.salary);
      expect(reconstructed.department, sample.department);
      expect(reconstructed.employmentStatus, sample.employmentStatus);
    });
  });

  group('EmployeeService Tests', () {
    late EmployeeService service;

    setUp(() {
      service = EmployeeService();
      service.resetToSampleData();
    });

    test('getAllEmployees returns initial pre-seeded sample data', () async {
      final list = await service.getAllEmployees();
      expect(list.length, greaterThanOrEqualTo(6));
      expect(list.any((e) => e.id == 'EMP-1001'), isTrue);
    });

    test('getEmployeeById returns matching employee for valid ID (case-insensitive)', () async {
      final emp = await service.getEmployeeById('emp-1001');
      expect(emp, isNotNull);
      expect(emp!.id, 'EMP-1001');
      expect(emp.fullName, 'Alexander Wright');
    });

    test('getEmployeeById returns null for non-existent ID', () async {
      final emp = await service.getEmployeeById('EMP-9999');
      expect(emp, isNull);
    });

    test('addEmployee prepends new record and assigns sequential ID if blank', () async {
      final newEmp = Employee(
        id: '',
        fullName: 'Test Employee',
        email: 'test.emp@bank.com',
        phone: '+1 555-4444',
        bankName: 'Apex Global Bank',
        branchName: 'HQ',
        branchCode: 'APX-HQ',
        department: 'IT & Systems',
        designation: 'Software Engineer',
        dateOfJoining: DateTime.now(),
        employmentStatus: 'Full-Time',
        salary: 95000.0,
        address: '1 Test Way',
      );

      final created = await service.addEmployee(newEmp);
      expect(created.id, startsWith('EMP-'));
      expect(created.fullName, 'Test Employee');

      final fetched = await service.getEmployeeById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.email, 'test.emp@bank.com');
    });

    test('addEmployee throws Exception on duplicate email', () async {
      final newEmp1 = Employee(
        id: '',
        fullName: 'First Person',
        email: 'duplicate@bank.com',
        phone: '+1 555-1111',
        bankName: 'Apex Global Bank',
        branchName: 'HQ',
        branchCode: 'APX-HQ',
        department: 'Operations',
        designation: 'Officer',
        dateOfJoining: DateTime.now(),
        employmentStatus: 'Full-Time',
        salary: 60000.0,
        address: '1 Address',
      );

      await service.addEmployee(newEmp1);

      final newEmp2 = newEmp1.copyWith(fullName: 'Second Person');
      expect(
        () async => await service.addEmployee(newEmp2),
        throwsA(isA<Exception>()),
      );
    });
  });
}
