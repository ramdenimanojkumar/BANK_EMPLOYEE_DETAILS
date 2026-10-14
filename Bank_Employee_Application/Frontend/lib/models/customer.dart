class Customer {
  final String customerId;
  final String fullName;
  final DateTime dateOfBirth;
  final String email;
  final String phone;
  final String address;
  final String accountNumber;
  final String accountType; // Savings / Current
  final String branchName;
  final String branchCode;
  final DateTime accountOpeningDate;
  final double accountBalance;
  final String accountStatus; // Active / Inactive

  const Customer({
    required this.customerId,
    required this.fullName,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.address,
    required this.accountNumber,
    required this.accountType,
    required this.branchName,
    required this.branchCode,
    required this.accountOpeningDate,
    required this.accountBalance,
    required this.accountStatus,
  });

  static const List<String> accountTypes = [
    'Savings',
    'Current',
  ];

  static const List<String> accountStatuses = [
    'Active',
    'Inactive',
  ];

  static const List<String> sampleBranches = [
    'Downtown Financial Center (APX-NYC-01)',
    'Wall Street Regional HQ (APX-NYC-02)',
    'Midtown Commercial Branch (APX-NYC-03)',
    'Fintech Innovation Hub (APX-NYC-04)',
    'Brooklyn Heights Branch (APX-BKL-01)',
    'Central City Main Branch (APX-CC-05)',
  ];

  Customer copyWith({
    String? customerId,
    String? fullName,
    DateTime? dateOfBirth,
    String? email,
    String? phone,
    String? address,
    String? accountNumber,
    String? accountType,
    String? branchName,
    String? branchCode,
    DateTime? accountOpeningDate,
    double? accountBalance,
    String? accountStatus,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      accountOpeningDate: accountOpeningDate ?? this.accountOpeningDate,
      accountBalance: accountBalance ?? this.accountBalance,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'email': email,
      'phone': phone,
      'address': address,
      'account_number': accountNumber,
      'account_type': accountType,
      'branch_name': branchName,
      'branch_code': branchCode,
      'account_opening_date': accountOpeningDate.toIso8601String().split('T').first,
      'account_balance': accountBalance,
      'account_status': accountStatus,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is DateTime) return dateVal;
      if (dateVal is String) {
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      }
      return DateTime.now();
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val) ?? 0.0;
      }
      return 0.0;
    }

    return Customer(
      customerId: (json['customer_id'] ?? json['customerId'] ?? json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString(),
      dateOfBirth: parseDate(json['date_of_birth'] ?? json['dateOfBirth']),
      email: (json['email'] ?? json['email_address'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? json['accountNumber'] ?? '').toString(),
      accountType: (json['account_type'] ?? json['accountType'] ?? 'Savings').toString(),
      branchName: (json['branch_name'] ?? json['branchName'] ?? '').toString(),
      branchCode: (json['branch_code'] ?? json['branchCode'] ?? '').toString(),
      accountOpeningDate: parseDate(json['account_opening_date'] ?? json['accountOpeningDate']),
      accountBalance: parseDouble(json['account_balance'] ?? json['accountBalance']),
      accountStatus: (json['account_status'] ?? json['accountStatus'] ?? 'Active').toString(),
    );
  }

  @override
  String toString() =>
      'Customer(id: $customerId, name: $fullName, acc: $accountNumber, type: $accountType, status: $accountStatus)';
}
