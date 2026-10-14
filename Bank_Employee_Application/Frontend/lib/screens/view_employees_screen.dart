import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_detail_modal.dart';

class ViewEmployeesScreen extends StatefulWidget {
  const ViewEmployeesScreen({super.key});

  @override
  State<ViewEmployeesScreen> createState() => _ViewEmployeesScreenState();
}

class _ViewEmployeesScreenState extends State<ViewEmployeesScreen> {
  final _employeeService = EmployeeService();
  final _searchIdController = TextEditingController();
  final _filterTextController = TextEditingController();

  List<Employee> _allEmployees = [];
  bool _isLoadingList = true;
  String? _listErrorMessage;

  // Search by ID State
  bool _isSearchingId = false;
  Employee? _searchedEmployee;
  bool _hasSearchedId = false;
  String _lastSearchedQuery = '';

  // Quick Table Filtering
  String _selectedDeptFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchIdController.dispose();
    _filterTextController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoadingList = true;
      _listErrorMessage = null;
    });

    try {
      final list = await _employeeService.getAllEmployees();
      if (!mounted) return;
      setState(() {
        _allEmployees = list;
        _isLoadingList = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listErrorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoadingList = false;
      });
    }
  }

  Future<void> _performIdSearch() async {
    final query = _searchIdController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an Employee ID to search (e.g. EMP-1001).'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    setState(() {
      _isSearchingId = true;
      _hasSearchedId = true;
      _lastSearchedQuery = query;
      _searchedEmployee = null;
    });

    try {
      final result = await _employeeService.getEmployeeById(query);
      if (!mounted) return;
      setState(() {
        _searchedEmployee = result;
        _isSearchingId = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchedEmployee = null;
        _isSearchingId = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _clearIdSearch() {
    _searchIdController.clear();
    setState(() {
      _searchedEmployee = null;
      _hasSearchedId = false;
      _lastSearchedQuery = '';
    });
  }

  List<Employee> get _filteredEmployees {
    return _allEmployees.where((emp) {
      final matchesDept = _selectedDeptFilter == 'All' || emp.department == _selectedDeptFilter;
      final query = _filterTextController.text.trim().toLowerCase();
      if (query.isEmpty) return matchesDept;

      final matchesQuery = emp.fullName.toLowerCase().contains(query) ||
          emp.id.toLowerCase().contains(query) ||
          emp.branchName.toLowerCase().contains(query) ||
          emp.designation.toLowerCase().contains(query) ||
          emp.phone.contains(query);

      return matchesDept && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
    final isTablet = screenWidth >= 650 && screenWidth < 950;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Header Banner
              _buildPageHeader(),
              const SizedBox(height: 24),

              // ==========================================
              // SECTION 2.B: RETRIEVE EMPLOYEE BY ID
              // ==========================================
              _buildSearchByIdSection(isDesktop),
              const SizedBox(height: 28),

              // ==========================================
              // SECTION 2.A: VIEW ALL EMPLOYEES
              // ==========================================
              _buildAllEmployeesSection(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
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
            child: const Icon(Icons.badge_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank Employee Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Retrieve individual records by ID or browse the active personnel directory',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Refresh Button
          IconButton(
            onPressed: _isLoadingList ? null : _loadEmployees,
            tooltip: 'Refresh Employee List',
            icon: _isLoadingList
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION 2.B: RETRIEVE EMPLOYEE BY ID WIDGETS
  // ==========================================================
  Widget _buildSearchByIdSection(bool isDesktop) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search_rounded, color: AppTheme.navyPrimary, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Retrieve Employee by ID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyPrimary,
                  ),
                ),
                const Spacer(),
                if (_hasSearchedId)
                  TextButton.icon(
                    onPressed: _clearIdSearch,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Clear Search'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter the employee registration ID to retrieve complete institutional records.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // Search Bar Input & Buttons
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchIdController,
                    onSubmitted: (_) => _performIdSearch(),
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Enter Employee ID (e.g. EMP-1001, EMP-1002)...',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      suffixIcon: _searchIdController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchIdController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSearchingId ? null : _performIdSearch,
                  icon: _isSearchingId
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search_rounded, size: 18),
                  label: Text(_isSearchingId ? 'Searching...' : 'Search'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),

            // Quick suggestion chips
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Quick Samples:',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                ),
                ...['EMP-1001', 'EMP-1002', 'EMP-1003', 'EMP-1004'].map((sampleId) {
                  return ActionChip(
                    label: Text(sampleId),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navyPrimary,
                    ),
                    backgroundColor: AppTheme.blueLight,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _searchIdController.text = sampleId;
                      _performIdSearch();
                    },
                  );
                }),
              ],
            ),

            // Search Results Panel
            if (_hasSearchedId) ...[
              const SizedBox(height: 20),
              const Divider(color: AppTheme.cardBorder),
              const SizedBox(height: 16),
              if (_searchedEmployee != null)
                _buildFoundEmployeeResult(_searchedEmployee!, isDesktop)
              else
                _buildEmployeeNotFound(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoundEmployeeResult(Employee emp, bool isDesktop) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.blueSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.blueAccent.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.navyPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  emp.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emp.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyPrimary,
                  ),
                ),
              ),
              StatusBadge(status: emp.employmentStatus),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textSecondary),
                onPressed: _clearIdSearch,
                tooltip: 'Dismiss Result',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder, height: 1),
          const SizedBox(height: 16),

          // 13 details responsive grid
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildResultField('Designation', emp.designation, Icons.work_rounded, isDesktop),
              _buildResultField('Department', emp.department, Icons.corporate_fare_rounded, isDesktop),
              _buildResultField('Bank Name', emp.bankName, Icons.account_balance_rounded, isDesktop),
              _buildResultField('Branch', '${emp.branchName} (${emp.branchCode})', Icons.location_on_rounded, isDesktop),
              _buildResultField('Email', emp.email, Icons.email_rounded, isDesktop),
              _buildResultField('Phone', emp.phone, Icons.phone_rounded, isDesktop),
              _buildResultField('Date of Joining', dateFormatter.format(emp.dateOfJoining), Icons.calendar_month_rounded, isDesktop),
              _buildResultField('Annual Salary', currencyFormatter.format(emp.salary), Icons.payments_rounded, isDesktop),
              _buildResultField('Residential Address', emp.address, Icons.home_rounded, isDesktop, fullWidth: true),
            ],
          ),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => EmployeeDetailModal.show(context, emp),
              icon: const Icon(Icons.launch_rounded, size: 16),
              label: const Text('Open Full Dossier Modal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultField(
    String label,
    String value,
    IconData icon,
    bool isDesktop, {
    bool fullWidth = false,
  }) {
    final width = fullWidth
        ? double.infinity
        : (isDesktop ? 260.0 : 200.0);

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeNotFound() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_off_rounded, color: Color(0xFFDC2626), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Not Found',
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No employee record matches ID "$_lastSearchedQuery". Please verify the ID code (e.g., EMP-1001) or check the All Employees directory below.',
                  style: const TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _clearIdSearch,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Clear and Search Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF991B1B),
                    side: const BorderSide(color: Color(0xFFF87171)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION 2.A: VIEW ALL EMPLOYEES WIDGETS
  // ==========================================================
  Widget _buildAllEmployeesSection(bool isDesktop) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title, Count Badge, Refresh Button
            Row(
              children: [
                const Icon(Icons.list_alt_rounded, color: AppTheme.navyPrimary, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'All Employees Directory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.blueLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredEmployees.length} of ${_allEmployees.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blueAccent,
                    ),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _isLoadingList ? null : _loadEmployees,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search filter & Department selector
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _filterTextController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Filter by name, ID, branch, designation, or phone...',
                      prefixIcon: const Icon(Icons.filter_list_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: _filterTextController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _filterTextController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDeptFilter,
                    isDense: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.corporate_fare_rounded, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: ['All', ...Employee.departments].map((dept) {
                      return DropdownMenuItem<String>(
                        value: dept,
                        child: Text(
                          dept == 'All' ? 'All Departments' : dept,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDeptFilter = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content Area (Loading / Error / Empty / Table / Cards)
            _buildDirectoryContent(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryContent(bool isDesktop) {
    if (_isLoadingList) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: const Column(
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: AppTheme.navyPrimary),
            SizedBox(height: 16),
            Text(
              'Loading employee records from system...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_listErrorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 36),
            const SizedBox(height: 10),
            Text(
              'Failed to load employees: $_listErrorMessage',
              style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadEmployees,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredEmployees.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded, size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'No employees match your filter criteria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing your search query or department filter.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _filterTextController.clear();
                setState(() {
                  _selectedDeptFilter = 'All';
                });
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    // Render Table on Desktop, Cards on Tablet/Mobile
    if (isDesktop) {
      return _buildDesktopTable();
    } else {
      return _buildMobileCards();
    }
  }

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1000),
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              columns: const [
                DataColumn(label: Text('EMPLOYEE ID')),
                DataColumn(label: Text('FULL NAME')),
                DataColumn(label: Text('DEPARTMENT')),
                DataColumn(label: Text('DESIGNATION')),
                DataColumn(label: Text('BRANCH')),
                DataColumn(label: Text('PHONE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: _filteredEmployees.map((emp) {
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.blueLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          emp.id,
                          style: const TextStyle(
                            color: AppTheme.blueAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        emp.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    DataCell(Text(emp.department)),
                    DataCell(
                      Text(
                        emp.designation,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    DataCell(Text(emp.branchName)),
                    DataCell(Text(emp.phone)),
                    DataCell(StatusBadge(status: emp.employmentStatus, isCompact: true)),
                    DataCell(
                      TextButton.icon(
                        onPressed: () => EmployeeDetailModal.show(context, emp),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.navyPrimary,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards() {
    return Column(
      children: _filteredEmployees.map((emp) {
        return EmployeeCard(employee: emp);
      }).toList(),
    );
  }
}
