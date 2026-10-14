import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class EmployeeService {
  // Singleton pattern for shared state in the Flutter app
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal() {
    _initSampleData();
  }

  /// Toggle this to `false` when the Django REST API is running.
  static const bool isMockMode = true;

  /// Base URL of the Django backend API
  static const String baseUrl = 'http://127.0.0.1:8000/api/employees/';

  // In-memory data store for frontend demonstration
  final List<Employee> _employees = [];

  void _initSampleData() {
    if (_employees.isNotEmpty) return;
    _employees.addAll([
      Employee(
        id: 'EMP-1001',
        fullName: 'Alexander Wright',
        email: 'a.wright@apexbank.com',
        phone: '+1 (555) 234-8901',
        bankName: 'Apex Global Bank',
        branchName: 'Downtown Financial Center',
        branchCode: 'APX-NYC-01',
        department: 'Retail Banking',
        designation: 'Senior Branch Manager',
        dateOfJoining: DateTime(2021, 3, 15),
        employmentStatus: 'Full-Time',
        salary: 115000.00,
        address: '450 Lexington Ave, Suite 1200, New York, NY 10017',
      ),
      Employee(
        id: 'EMP-1002',
        fullName: 'Elena Rostova',
        email: 'e.rostova@apexbank.com',
        phone: '+1 (555) 345-6789',
        bankName: 'Apex Global Bank',
        branchName: 'Wall Street Regional HQ',
        branchCode: 'APX-NYC-02',
        department: 'Risk & Compliance',
        designation: 'Chief Compliance Auditor',
        dateOfJoining: DateTime(2022, 7, 1),
        employmentStatus: 'Full-Time',
        salary: 132000.00,
        address: '88 Pine Street, Floor 18, New York, NY 10005',
      ),
      Employee(
        id: 'EMP-1003',
        fullName: 'Marcus Vance',
        email: 'm.vance@apexbank.com',
        phone: '+1 (555) 890-1234',
        bankName: 'Apex Global Bank',
        branchName: 'Midtown Commercial Branch',
        branchCode: 'APX-NYC-03',
        department: 'Corporate Banking',
        designation: 'Vice President, Commercial Credit',
        dateOfJoining: DateTime(2020, 11, 20),
        employmentStatus: 'Full-Time',
        salary: 148000.00,
        address: '1221 Avenue of the Americas, New York, NY 10020',
      ),
      Employee(
        id: 'EMP-1004',
        fullName: 'Priya Sharma',
        email: 'p.sharma@apexbank.com',
        phone: '+1 (555) 678-9012',
        bankName: 'Apex Global Bank',
        branchName: 'Fintech Innovation Hub',
        branchCode: 'APX-NYC-04',
        department: 'IT & Systems',
        designation: 'Lead Core-Banking Systems Architect',
        dateOfJoining: DateTime(2023, 1, 10),
        employmentStatus: 'Full-Time',
        salary: 140000.00,
        address: '335 Madison Ave, 5th Floor, New York, NY 10017',
      ),
      Employee(
        id: 'EMP-1005',
        fullName: 'Julian Hayes',
        email: 'j.hayes@apexbank.com',
        phone: '+1 (555) 432-1098',
        bankName: 'Apex Global Bank',
        branchName: 'Brooklyn Heights Branch',
        branchCode: 'APX-BKL-01',
        department: 'Loans & Mortgages',
        designation: 'Residential Mortgage Underwriter',
        dateOfJoining: DateTime(2024, 2, 1),
        employmentStatus: 'Probation',
        salary: 82000.00,
        address: '180 Montague Street, Brooklyn, NY 11201',
      ),
      Employee(
        id: 'EMP-1006',
        fullName: 'Sophia Martinez',
        email: 's.martinez@apexbank.com',
        phone: '+1 (555) 987-6543',
        bankName: 'Apex Global Bank',
        branchName: 'Downtown Financial Center',
        branchCode: 'APX-NYC-01',
        department: 'Customer Service',
        designation: 'Senior Client Relations Officer',
        dateOfJoining: DateTime(2023, 9, 15),
        employmentStatus: 'Full-Time',
        salary: 68500.00,
        address: '75 Wall St, Apt 9B, New York, NY 10005',
      ),
    ]);
  }

  /// Generates the next sequential ID for demo frontend usage (e.g., EMP-1007)
  String generateNextId() {
    int maxIdNum = 1000;
    for (final emp in _employees) {
      final parts = emp.id.split('-');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && num > maxIdNum) {
          maxIdNum = num;
        }
      }
    }
    return 'EMP-${maxIdNum + 1}';
  }

  /// Retrieve all employees
  Future<List<Employee>> getAllEmployees() async {
    if (isMockMode) {
      // Simulate realistic network latency for UI responsiveness
      await Future.delayed(const Duration(milliseconds: 350));
      return List<Employee>.unmodifiable(_employees);
    } else {
      try {
        final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((item) => Employee.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Failed to load employees from server (Status ${response.statusCode})');
        }
      } catch (e) {
        throw Exception('Network error connecting to $baseUrl: $e');
      }
    }
  }

  /// Retrieve an employee by ID (case-insensitive, trimmed)
  Future<Employee?> getEmployeeById(String id) async {
    final cleanId = id.trim().toUpperCase();
    if (cleanId.isEmpty) return null;

    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final matches = _employees.where((emp) => emp.id.toUpperCase() == cleanId);
      if (matches.isNotEmpty) {
        return matches.first;
      }
      return null;
    } else {
      try {
        final url = Uri.parse('$baseUrl$cleanId/');
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return Employee.fromJson(data as Map<String, dynamic>);
        } else if (response.statusCode == 404) {
          return null;
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching employee $cleanId: $e');
      }
    }
  }

  /// Add a new employee
  Future<Employee> addEmployee(Employee employee) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));

      // Duplicate email check
      final emailExists = _employees.any(
        (e) => e.email.trim().toLowerCase() == employee.email.trim().toLowerCase(),
      );
      if (emailExists) {
        throw Exception('An employee with email "${employee.email}" is already registered.');
      }

      // Assign ID if blank or placeholder
      final assignedId = (employee.id.isEmpty || employee.id == 'AUTO')
          ? generateNextId()
          : employee.id;

      final newEmployee = employee.copyWith(id: assignedId);
      // Prepend to display newest first
      _employees.insert(0, newEmployee);
      return newEmployee;
    } else {
      try {
        final response = await http
            .post(
              Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(employee.toJson()),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final created = Employee.fromJson(data as Map<String, dynamic>);
          _employees.insert(0, created);
          return created;
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? errorData['error'] ?? 'Server rejected employee creation');
        }
      } catch (e) {
        throw Exception('Submission failed: $e');
      }
    }
  }

  /// Helper to reset or seed fresh test data if needed
  void resetToSampleData() {
    _employees.clear();
    _initSampleData();
  }
}
