import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/customer.dart';

class CustomerApiException implements Exception {
  final String message;
  final int? statusCode;

  const CustomerApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class CustomerService {
  static final CustomerService _instance = CustomerService._internal(
    http.Client(),
  );

  factory CustomerService() => _instance;

  CustomerService._internal(this._client);

  CustomerService.testing(this._client);

  final http.Client _client;

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const String baseUrl = '$apiBaseUrl/customers/';
  static const Duration _requestTimeout = Duration(seconds: 10);

  static List<Customer> get previewLayoutTemplates => [
    Customer(
      customerId: 'CUST-1001',
      fullName: 'Eleanor Vance',
      dateOfBirth: DateTime(1988, 4, 12),
      email: 'eleanor.vance@example.com',
      phone: '+1 (555) 234-8901',
      address: '742 Evergreen Terrace, New York, NY 10001',
      accountNumber: '100482910384',
      accountType: 'Savings',
      branchName: 'Downtown Financial Center',
      branchCode: 'APX-NYC-01',
      accountOpeningDate: DateTime(2021, 1, 15),
      accountBalance: 24850.50,
      accountStatus: 'Active',
    ),
    Customer(
      customerId: 'CUST-1002',
      fullName: 'Marcus Sterling',
      dateOfBirth: DateTime(1979, 9, 28),
      email: 'm.sterling@example.com',
      phone: '+1 (555) 345-6789',
      address: '88 Wall Street, Suite 1400, New York, NY 10005',
      accountNumber: '200938471920',
      accountType: 'Current',
      branchName: 'Wall Street Regional HQ',
      branchCode: 'APX-NYC-02',
      accountOpeningDate: DateTime(2019, 6, 20),
      accountBalance: 145000.00,
      accountStatus: 'Active',
    ),
    Customer(
      customerId: 'CUST-1003',
      fullName: 'Sophia Ramirez',
      dateOfBirth: DateTime(1995, 11, 3),
      email: 'sophia.ramirez@example.com',
      phone: '+1 (555) 890-1234',
      address: '335 Madison Ave, Floor 12, New York, NY 10017',
      accountNumber: '100829301948',
      accountType: 'Savings',
      branchName: 'Fintech Innovation Hub',
      branchCode: 'APX-NYC-04',
      accountOpeningDate: DateTime(2023, 3, 10),
      accountBalance: 8750.25,
      accountStatus: 'Inactive',
    ),
  ];

  Future<List<Customer>> getAllCustomers() async {
    final response = await _client
        .get(Uri.parse(baseUrl))
        .timeout(_requestTimeout);
    _throwIfUnsuccessful(response);

    final payload = jsonDecode(response.body);
    if (payload is! List) {
      throw const FormatException(
        'The customer API returned an invalid list response.',
      );
    }

    return payload
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'The customer API returned an invalid customer record.',
            );
          }
          return Customer.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<Customer?> getCustomerById(String id) async {
    final cleanId = id.trim().toUpperCase();
    if (cleanId.isEmpty) return null;

    final uri = Uri.parse('$baseUrl${Uri.encodeComponent(cleanId)}/');
    final response = await _client.get(uri).timeout(_requestTimeout);
    if (response.statusCode == 404) return null;
    _throwIfUnsuccessful(response);

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException(
        'The customer API returned an invalid customer response.',
      );
    }
    return Customer.fromJson(payload);
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _client
        .post(
          Uri.parse(baseUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(customer.toJson()),
        )
        .timeout(_requestTimeout);
    _throwIfUnsuccessful(response);

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException(
        'The customer API returned an invalid customer response.',
      );
    }
    return Customer.fromJson(payload);
  }

  Future<bool> checkBackendConnection() async {
    try {
      final uri = Uri.parse('$apiBaseUrl/health/');
      final response = await _client.get(uri).timeout(_requestTimeout);
      return response.statusCode == 200;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  static void _throwIfUnsuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message = 'The server returned HTTP ${response.statusCode}.';
    try {
      final payload = jsonDecode(response.body);
      if (payload is Map<String, dynamic>) {
        final details = payload.values
            .expand((value) => value is List ? value : [value])
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty)
            .join(' ');
        if (details.isNotEmpty) message = details;
      }
    } on FormatException {
      // Keep the explicit HTTP status message when the response is not JSON.
    }

    throw CustomerApiException(message, statusCode: response.statusCode);
  }
}
