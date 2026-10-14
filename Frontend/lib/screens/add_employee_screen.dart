import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../theme/app_theme.dart';
import '../widgets/employee_form_field.dart';

class AddEmployeeScreen extends StatefulWidget {
  final VoidCallback? onEmployeeAdded;

  const AddEmployeeScreen({
    super.key,
    this.onEmployeeAdded,
  });

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeService = EmployeeService();

  // Form Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankNameController = TextEditingController(text: 'Apex Global Bank');
  final _branchNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _designationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedDepartment;
  String _selectedEmploymentStatus = 'Full-Time';
  DateTime? _selectedDateOfJoining = DateTime.now();

  bool _isSubmitting = false;
  String _nextSampleId = '';

  @override
  void initState() {
    super.initState();
    _refreshNextId();
  }

  void _refreshNextId() {
    setState(() {
      _nextSampleId = _employeeService.generateNextId();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _branchCodeController.dispose();
    _designationController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _bankNameController.text = 'Apex Global Bank';
    _branchNameController.clear();
    _branchCodeController.clear();
    _designationController.clear();
    _salaryController.clear();
    _addressController.clear();
    setState(() {
      _selectedDepartment = null;
      _selectedEmploymentStatus = 'Full-Time';
      _selectedDateOfJoining = DateTime.now();
    });
    _refreshNextId();
  }

  Future<void> _submitForm() async {
    // Prevent duplicate clicks while submitting
    if (_isSubmitting) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Please fill all required fields correctly before submitting.'),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_selectedDateOfJoining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Date of Joining.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final salary = double.tryParse(_salaryController.text.trim()) ?? 0.0;

      final newEmployee = Employee(
        id: _nextSampleId,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        bankName: _bankNameController.text.trim(),
        branchName: _branchNameController.text.trim(),
        branchCode: _branchCodeController.text.trim(),
        department: _selectedDepartment!,
        designation: _designationController.text.trim(),
        dateOfJoining: _selectedDateOfJoining!,
        employmentStatus: _selectedEmploymentStatus,
        salary: salary,
        address: _addressController.text.trim(),
      );

      final created = await _employeeService.addEmployee(newEmployee);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Employee registered successfully! Assigned ID: ${created.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View Directory',
            textColor: Colors.white,
            onPressed: () {
              widget.onEmployeeAdded?.call();
            },
          ),
        ),
      );

      _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Input Validators
  String? _validateRequired(String? val, String fieldName) {
    if (val == null || val.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+(\.[a-zA-Z]{2,})+$');
    if (!emailRegex.hasMatch(val.trim())) {
      return 'Enter a valid corporate email (e.g. user@bank.com)';
    }
    return null;
  }

  String? _validatePhone(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = val.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Phone number must have between 7 and 15 digits';
    }
    return null;
  }

  String? _validateSalary(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Salary is required';
    }
    final salary = double.tryParse(val.trim());
    if (salary == null) {
      return 'Please enter a valid numeric salary';
    }
    if (salary <= 0) {
      return 'Salary must be greater than zero';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header Banner
              _buildPageHeader(isDesktop),
              const SizedBox(height: 24),

              // Form Container Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Subtitle
                        Row(
                          children: [
                            const Icon(Icons.person_add_rounded, color: AppTheme.navyPrimary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Employee Registration Form',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.navyPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.blueLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '* All fields required',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (!isDesktop) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.blueLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '* All fields required',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.blueAccent,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Provide official employment credentials and banking assignment details.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.cardBorder, height: 1),
                        const SizedBox(height: 24),

                        // Section A: Personal Information
                        _buildSectionHeading('1. Personal & Contact Details'),
                        const SizedBox(height: 16),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: EmployeeTextField(
                                  label: 'Full Name',
                                  hint: 'e.g. Jonathan R. Miller',
                                  controller: _fullNameController,
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) => _validateRequired(v, 'Full Name'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: EmployeeTextField(
                                  label: 'Email Address',
                                  hint: 'e.g. j.miller@apexbank.com',
                                  controller: _emailController,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: EmployeeTextField(
                                  label: 'Phone Number',
                                  hint: 'e.g. +1 (555) 234-5678',
                                  controller: _phoneController,
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          EmployeeTextField(
                            label: 'Full Name',
                            hint: 'e.g. Jonathan R. Miller',
                            controller: _fullNameController,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (v) => _validateRequired(v, 'Full Name'),
                          ),
                          const SizedBox(height: 16),
                          EmployeeTextField(
                            label: 'Email Address',
                            hint: 'e.g. j.miller@apexbank.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          EmployeeTextField(
                            label: 'Phone Number',
                            hint: 'e.g. +1 (555) 234-5678',
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                          ),
                        ],

                        const SizedBox(height: 24),
                        // Section B: Banking & Branch
                        _buildSectionHeading('2. Bank & Branch Information'),
                        const SizedBox(height: 16),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: EmployeeTextField(
                                  label: 'Bank Name',
                                  hint: 'e.g. Apex Global Bank',
                                  controller: _bankNameController,
                                  prefixIcon: Icons.account_balance_rounded,
                                  validator: (v) => _validateRequired(v, 'Bank Name'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: EmployeeTextField(
                                  label: 'Branch Name',
                                  hint: 'e.g. Downtown Financial Center',
                                  controller: _branchNameController,
                                  prefixIcon: Icons.location_city_rounded,
                                  validator: (v) => _validateRequired(v, 'Branch Name'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: EmployeeTextField(
                                  label: 'Branch Code',
                                  hint: 'e.g. APX-NYC-01',
                                  controller: _branchCodeController,
                                  prefixIcon: Icons.tag_rounded,
                                  validator: (v) => _validateRequired(v, 'Branch Code'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          EmployeeTextField(
                            label: 'Bank Name',
                            hint: 'e.g. Apex Global Bank',
                            controller: _bankNameController,
                            prefixIcon: Icons.account_balance_rounded,
                            validator: (v) => _validateRequired(v, 'Bank Name'),
                          ),
                          const SizedBox(height: 16),
                          EmployeeTextField(
                            label: 'Branch Name',
                            hint: 'e.g. Downtown Financial Center',
                            controller: _branchNameController,
                            prefixIcon: Icons.location_city_rounded,
                            validator: (v) => _validateRequired(v, 'Branch Name'),
                          ),
                          const SizedBox(height: 16),
                          EmployeeTextField(
                            label: 'Branch Code',
                            hint: 'e.g. APX-NYC-01',
                            controller: _branchCodeController,
                            prefixIcon: Icons.tag_rounded,
                            validator: (v) => _validateRequired(v, 'Branch Code'),
                          ),
                        ],

                        const SizedBox(height: 24),
                        // Section C: Department & Role
                        _buildSectionHeading('3. Position & Compensation'),
                        const SizedBox(height: 16),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: EmployeeDropdownField(
                                  label: 'Department',
                                  hint: 'Select Department',
                                  value: _selectedDepartment,
                                  items: Employee.departments,
                                  prefixIcon: Icons.corporate_fare_rounded,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedDepartment = val;
                                    });
                                  },
                                  validator: (v) => v == null ? 'Select a department' : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: EmployeeTextField(
                                  label: 'Designation',
                                  hint: 'e.g. Senior Credit Underwriter',
                                  controller: _designationController,
                                  prefixIcon: Icons.work_outline_rounded,
                                  validator: (v) => _validateRequired(v, 'Designation'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: EmployeeDateField(
                                  label: 'Date of Joining',
                                  selectedDate: _selectedDateOfJoining,
                                  onDateSelected: (date) {
                                    setState(() {
                                      _selectedDateOfJoining = date;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: EmployeeDropdownField(
                                  label: 'Employment Status',
                                  value: _selectedEmploymentStatus,
                                  items: Employee.employmentStatuses,
                                  prefixIcon: Icons.badge_outlined,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedEmploymentStatus = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: EmployeeTextField(
                                  label: 'Annual Salary (\$)',
                                  hint: 'e.g. 95000',
                                  controller: _salaryController,
                                  prefixIcon: Icons.attach_money_rounded,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  validator: _validateSalary,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          EmployeeDropdownField(
                            label: 'Department',
                            hint: 'Select Department',
                            value: _selectedDepartment,
                            items: Employee.departments,
                            prefixIcon: Icons.corporate_fare_rounded,
                            onChanged: (val) {
                              setState(() {
                                _selectedDepartment = val;
                              });
                            },
                            validator: (v) => v == null ? 'Select a department' : null,
                          ),
                          const SizedBox(height: 16),
                          EmployeeTextField(
                            label: 'Designation',
                            hint: 'e.g. Senior Credit Underwriter',
                            controller: _designationController,
                            prefixIcon: Icons.work_outline_rounded,
                            validator: (v) => _validateRequired(v, 'Designation'),
                          ),
                          const SizedBox(height: 16),
                          EmployeeDateField(
                            label: 'Date of Joining',
                            selectedDate: _selectedDateOfJoining,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDateOfJoining = date;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          EmployeeDropdownField(
                            label: 'Employment Status',
                            value: _selectedEmploymentStatus,
                            items: Employee.employmentStatuses,
                            prefixIcon: Icons.badge_outlined,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedEmploymentStatus = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          EmployeeTextField(
                            label: 'Annual Salary (\$)',
                            hint: 'e.g. 95000',
                            controller: _salaryController,
                            prefixIcon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: _validateSalary,
                          ),
                        ],

                        const SizedBox(height: 24),
                        // Section D: Address
                        _buildSectionHeading('4. Residential Address'),
                        const SizedBox(height: 16),

                        EmployeeTextField(
                          label: 'Full Address',
                          hint: 'Street, Building/Apartment, City, State, ZIP Code',
                          controller: _addressController,
                          prefixIcon: Icons.home_outlined,
                          maxLines: 3,
                          validator: (v) => _validateRequired(v, 'Residential Address'),
                        ),

                        const SizedBox(height: 32),
                        const Divider(color: AppTheme.cardBorder, height: 1),
                        const SizedBox(height: 24),

                        // Form Action Buttons
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _isSubmitting ? null : _clearForm,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Clear Form'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitForm,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded, size: 18),
                                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Employee'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDark.withValues(alpha: 0.12),
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
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Employee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Register and onboard personnel into the banking database',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tag_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Next ID Preview: $_nextSampleId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.navyPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}
