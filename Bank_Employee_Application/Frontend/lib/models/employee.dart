class Employee {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String bankName;
  final String branchName;
  final String branchCode;
  final String department;
  final String designation;
  final DateTime dateOfJoining;
  final String employmentStatus;
  final double salary;
  final String address;

  const Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bankName,
    required this.branchName,
    required this.branchCode,
    required this.department,
    required this.designation,
    required this.dateOfJoining,
    required this.employmentStatus,
    required this.salary,
    required this.address,
  });

  static const List<String> departments = [
    'Retail Banking',
    'Corporate Banking',
    'Loans & Mortgages',
    'Customer Service',
    'IT & Systems',
    'Risk & Compliance',
    'Operations',
    'Human Resources',
    'Wealth Management',
    'Treasury & Forex',
  ];

  static const List<String> employmentStatuses = [
    'Full-Time',
    'Probation',
    'Contract',
    'Part-Time',
    'Intern',
  ];

  static const List<String> sampleBanks = [
    'Apex Global Bank',
    'Metropolis Federal Bank',
    'Horizon Commercial Bank',
    'First National Bank',
    'Crown Trust Bank',
  ];

  Employee copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? bankName,
    String? branchName,
    String? branchCode,
    String? department,
    String? designation,
    DateTime? dateOfJoining,
    String? employmentStatus,
    double? salary,
    String? address,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      salary: salary ?? this.salary,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'bank_name': bankName,
      'branch_name': branchName,
      'branch_code': branchCode,
      'department': department,
      'designation': designation,
      'date_of_joining': dateOfJoining.toIso8601String().split('T').first,
      'employment_status': employmentStatus,
      'salary': salary,
      'address': address,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is DateTime) return dateVal;
      if (dateVal is String) {
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      }
      return DateTime.now();
    }

    double parseSalary(dynamic salaryVal) {
      if (salaryVal is num) return salaryVal.toDouble();
      if (salaryVal is String) {
        return double.tryParse(salaryVal) ?? 0.0;
      }
      return 0.0;
    }

    return Employee(
      id: (json['id'] ?? json['employee_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? json['email_address'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      bankName: (json['bank_name'] ?? json['bankName'] ?? '').toString(),
      branchName: (json['branch_name'] ?? json['branchName'] ?? '').toString(),
      branchCode: (json['branch_code'] ?? json['branchCode'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      designation: (json['designation'] ?? '').toString(),
      dateOfJoining: parseDate(json['date_of_joining'] ?? json['dateOfJoining']),
      employmentStatus: (json['employment_status'] ?? json['employmentStatus'] ?? 'Full-Time').toString(),
      salary: parseSalary(json['salary']),
      address: (json['address'] ?? '').toString(),
    );
  }

  @override
  String toString() => 'Employee(id: $id, name: $fullName, dept: $department, role: $designation)';
}
