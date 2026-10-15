import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/customer_form_field.dart';

class AddCustomerScreen extends StatefulWidget {
  final VoidCallback? onNavigateToView;

  const AddCustomerScreen({super.key, this.onNavigateToView});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = CustomerService();

  // Form Controllers (Temporary state during user entry)
  final _customerIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _branchNameController = TextEditingController(
    text: 'Downtown Financial Center',
  );
  final _branchCodeController = TextEditingController(text: 'APX-NYC-01');
  final _accountBalanceController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  DateTime? _selectedAccountOpeningDate = DateTime.now();
  String _selectedAccountType = 'Savings';
  String _selectedAccountStatus = 'Active';

  bool _isSubmitting = false;

  @override
  void dispose() {
    _customerIdController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _accountNumberController.dispose();
    _branchNameController.dispose();
    _branchCodeController.dispose();
    _accountBalanceController.dispose();
    super.dispose();
  }

  /// Clears temporary form values
  void _clearForm() {
    _formKey.currentState?.reset();
    _customerIdController.clear();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _accountNumberController.clear();
    _branchNameController.text = 'Downtown Financial Center';
    _branchCodeController.text = 'APX-NYC-01';
    _accountBalanceController.clear();

    setState(() {
      _selectedDateOfBirth = null;
      _selectedAccountOpeningDate = DateTime.now();
      _selectedAccountType = 'Savings';
      _selectedAccountStatus = 'Active';
      _isSubmitting = false;
    });
  }

  /// Handles form submission.
  /// Strictly follows Requirement 6:
  /// - Does NOT store data in-memory or in local persistence.
  /// - Does NOT pretend the customer was saved.
  /// - Displays validation confirmation + clear backend connection notification.
  /// - Clears temporary form fields upon completion.
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please correct the highlighted form errors before submitting.',
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cake_outlined, color: Colors.white),
              SizedBox(width: 10),
              Text('Please select the customer\'s Date of Birth.'),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_selectedAccountOpeningDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: Colors.white),
              SizedBox(width: 10),
              Text('Please select the Account Opening Date.'),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Capture temporary data snapshot for modal summary
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final parsedBalance =
        double.tryParse(_accountBalanceController.text.trim()) ?? 0.0;

    final customerSnapshot = Customer(
      customerId: _customerIdController.text.trim().toUpperCase(),
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _selectedDateOfBirth!,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountType: _selectedAccountType,
      branchName: _branchNameController.text.trim(),
      branchCode: _branchCodeController.text.trim().toUpperCase(),
      accountOpeningDate: _selectedAccountOpeningDate!,
      accountBalance: parsedBalance,
      accountStatus: _selectedAccountStatus,
    );

    try {
      await _customerService.createCustomer(customerSnapshot);
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer was not saved: $error'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.verified_outlined,
                color: AppTheme.blueAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Customer Saved Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navyPrimary,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This customer record has been saved to the backend database.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF065F46),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Saved Record Summary:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.navyPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildModalRow('Customer ID:', customerSnapshot.customerId),
                    _buildModalRow('Full Name:', customerSnapshot.fullName),
                    _buildModalRow(
                      'Date of Birth:',
                      dateFormatter.format(customerSnapshot.dateOfBirth),
                    ),
                    _buildModalRow('Email:', customerSnapshot.email),
                    _buildModalRow('Phone:', customerSnapshot.phone),
                    _buildModalRow(
                      'Account Number:',
                      customerSnapshot.accountNumber,
                    ),
                    _buildModalRow(
                      'Account Type:',
                      customerSnapshot.accountType,
                    ),
                    _buildModalRow(
                      'Branch:',
                      '${customerSnapshot.branchName} (${customerSnapshot.branchCode})',
                    ),
                    _buildModalRow(
                      'Opening Date:',
                      dateFormatter.format(customerSnapshot.accountOpeningDate),
                    ),
                    _buildModalRow(
                      'Account Balance:',
                      currencyFormatter.format(customerSnapshot.accountBalance),
                    ),
                    _buildModalRow(
                      'Account Status:',
                      customerSnapshot.accountStatus,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Close & Clear Form'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onNavigateToView?.call();
            },
            icon: const Icon(Icons.people_alt_rounded, size: 16),
            label: const Text('Go to View Customers'),
          ),
        ],
      ),
    );

    if (mounted) {
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.cleaning_services_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 10),
              Text('Temporary form values cleared. Ready for next entry.'),
            ],
          ),
          backgroundColor: AppTheme.navyPrimary,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
    final isTablet = screenWidth >= 650 && screenWidth < 950;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
            vertical: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Header Banner
                _buildHeaderBanner(),
                const SizedBox(height: 20),

                // Notice Banner regarding Stateless Frontend Architecture
                _buildStatelessNotice(),
                const SizedBox(height: 24),

                // Card 1: Personal KYC & Identification
                _buildPersonalDetailsCard(isDesktop),
                const SizedBox(height: 20),

                // Card 2: Contact Information
                _buildContactDetailsCard(isDesktop),
                const SizedBox(height: 20),

                // Card 3: Bank Account & Branch Particulars
                _buildAccountDetailsCard(isDesktop),
                const SizedBox(height: 28),

                // Submit and Clear Action Bar
                _buildActionBar(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDark.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Customer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Register new client KYC particulars, branch association, and account specifications',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatelessNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF166534),
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Frontend Interface Ready: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'This form performs client-side field validation. In alignment with banking security architecture, customer records are neither stored nor cached locally in the frontend. Connect the backend database to store persistent records.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle(
              Icons.badge_outlined,
              '1. Personal & KYC Identification',
            ),
            const SizedBox(height: 20),
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomerTextField(
                      label: 'Customer ID',
                      hint: 'e.g. CUST-1001, CUST-2024',
                      controller: _customerIdController,
                      prefixIcon: Icons.fingerprint_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Customer ID is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Customer ID must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerTextField(
                      label: 'Full Name',
                      hint: 'e.g. Johnathan Doe',
                      controller: _fullNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomerTextField(
                label: 'Customer ID',
                hint: 'e.g. CUST-1001',
                controller: _customerIdController,
                prefixIcon: Icons.fingerprint_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer ID is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Customer ID must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomerTextField(
                label: 'Full Name',
                hint: 'e.g. Johnathan Doe',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Date of Birth & Residential Address
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomerDateField(
                      label: 'Date of Birth',
                      hintText: 'Select Date of Birth',
                      icon: Icons.cake_outlined,
                      selectedDate: _selectedDateOfBirth,
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now().subtract(
                        const Duration(days: 365 * 10),
                      ),
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDateOfBirth = date;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomerTextField(
                      label: 'Residential Address',
                      hint: 'House/Street, Suite/Apartment, City, State, ZIP',
                      controller: _addressController,
                      prefixIcon: Icons.home_outlined,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        if (value.trim().length < 5) {
                          return 'Please provide a valid comprehensive address';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomerDateField(
                label: 'Date of Birth',
                hintText: 'Select Date of Birth',
                icon: Icons.cake_outlined,
                selectedDate: _selectedDateOfBirth,
                firstDate: DateTime(1920),
                lastDate: DateTime.now().subtract(
                  const Duration(days: 365 * 10),
                ),
                onDateSelected: (date) {
                  setState(() {
                    _selectedDateOfBirth = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomerTextField(
                label: 'Residential Address',
                hint: 'House/Street, City, State, ZIP',
                controller: _addressController,
                prefixIcon: Icons.home_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  if (value.trim().length < 5) {
                    return 'Please provide a valid comprehensive address';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetailsCard(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle(
              Icons.contact_mail_outlined,
              '2. Contact Information',
            ),
            const SizedBox(height: 20),
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomerTextField(
                      label: 'Email Address',
                      hint: 'e.g. customer@domain.com',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email address is required';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerTextField(
                      label: 'Phone Number',
                      hint: 'e.g. +1 (555) 019-2834',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        final digits = value.replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 7 || digits.length > 15) {
                          return 'Phone must be between 7 and 15 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomerTextField(
                label: 'Email Address',
                hint: 'e.g. customer@domain.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email address is required';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomerTextField(
                label: 'Phone Number',
                hint: 'e.g. +1 (555) 019-2834',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final digits = value.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 7 || digits.length > 15) {
                    return 'Phone must be between 7 and 15 digits';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsCard(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle(
              Icons.account_balance_outlined,
              '3. Bank Account & Branch Details',
            ),
            const SizedBox(height: 20),

            // Account Number & Account Type
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomerTextField(
                      label: 'Account Number',
                      hint: 'e.g. 100982347120',
                      controller: _accountNumberController,
                      prefixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account Number is required';
                        }
                        if (value.trim().length < 8 ||
                            value.trim().length > 18) {
                          return 'Account number must be 8-18 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerDropdownField(
                      label: 'Account Type',
                      value: _selectedAccountType,
                      items: Customer.accountTypes,
                      prefixIcon: Icons.account_balance_wallet_outlined,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedAccountType = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomerTextField(
                label: 'Account Number',
                hint: 'e.g. 100982347120',
                controller: _accountNumberController,
                prefixIcon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Account Number is required';
                  }
                  if (value.trim().length < 8 || value.trim().length > 18) {
                    return 'Account number must be 8-18 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomerDropdownField(
                label: 'Account Type',
                value: _selectedAccountType,
                items: Customer.accountTypes,
                prefixIcon: Icons.account_balance_wallet_outlined,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedAccountType = val;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),

            // Branch Name & Branch Code
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomerTextField(
                      label: 'Branch Name',
                      hint: 'e.g. Downtown Financial Center',
                      controller: _branchNameController,
                      prefixIcon: Icons.location_city_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Branch Name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerTextField(
                      label: 'Branch Code',
                      hint: 'e.g. APX-NYC-01',
                      controller: _branchCodeController,
                      prefixIcon: Icons.numbers_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Branch Code is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomerTextField(
                label: 'Branch Name',
                hint: 'e.g. Downtown Financial Center',
                controller: _branchNameController,
                prefixIcon: Icons.location_city_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Branch Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomerTextField(
                label: 'Branch Code',
                hint: 'e.g. APX-NYC-01',
                controller: _branchCodeController,
                prefixIcon: Icons.numbers_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Branch Code is required';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Account Opening Date, Balance, and Status
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomerDateField(
                      label: 'Account Opening Date',
                      hintText: 'Select Opening Date',
                      icon: Icons.calendar_month_outlined,
                      selectedDate: _selectedAccountOpeningDate,
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      onDateSelected: (date) {
                        setState(() {
                          _selectedAccountOpeningDate = date;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerTextField(
                      label: 'Account Balance (\$ USD)',
                      hint: 'e.g. 5000.00',
                      controller: _accountBalanceController,
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Initial Account Balance is required';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null) {
                          return 'Please enter a valid numeric balance';
                        }
                        if (amount < 0) {
                          return 'Account balance cannot be negative';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerDropdownField(
                      label: 'Account Status',
                      value: _selectedAccountStatus,
                      items: Customer.accountStatuses,
                      prefixIcon: Icons.toggle_on_outlined,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedAccountStatus = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomerDateField(
                label: 'Account Opening Date',
                hintText: 'Select Opening Date',
                icon: Icons.calendar_month_outlined,
                selectedDate: _selectedAccountOpeningDate,
                firstDate: DateTime(1990),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateSelected: (date) {
                  setState(() {
                    _selectedAccountOpeningDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomerTextField(
                label: 'Account Balance (\$ USD)',
                hint: 'e.g. 5000.00',
                controller: _accountBalanceController,
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Initial Account Balance is required';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null) {
                    return 'Please enter a valid numeric balance';
                  }
                  if (amount < 0) {
                    return 'Account balance cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomerDropdownField(
                label: 'Account Status',
                value: _selectedAccountStatus,
                items: Customer.accountStatuses,
                prefixIcon: Icons.toggle_on_outlined,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedAccountStatus = val;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.navyPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.navyPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 520;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                          ),
                    label: Text(
                      _isSubmitting ? 'Saving...' : 'Submit Customer Details',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navyPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _clearForm,
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: const Text('Clear Form'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _clearForm,
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: const Text('Clear Form'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                          ),
                    label: Text(
                      _isSubmitting ? 'Saving...' : 'Submit Customer Details',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navyPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
