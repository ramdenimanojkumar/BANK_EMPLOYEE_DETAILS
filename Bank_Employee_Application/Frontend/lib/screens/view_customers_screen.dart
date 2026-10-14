import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_detail_modal.dart';

enum DirectoryViewState {
  disconnected,
  loading,
  empty,
  error,
  layoutPreview,
}

class ViewCustomersScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAdd;

  const ViewCustomersScreen({
    super.key,
    this.onNavigateToAdd,
  });

  @override
  State<ViewCustomersScreen> createState() => _ViewCustomersScreenState();
}

class _ViewCustomersScreenState extends State<ViewCustomersScreen> {
  final _customerService = CustomerService();
  final _searchIdController = TextEditingController();
  final _filterTextController = TextEditingController();

  // Search by ID State
  bool _isSearchingId = false;
  bool _hasSearchedId = false;
  String _lastSearchedQuery = '';

  // Directory UI State (Default is disconnected, per requirement 6)
  DirectoryViewState _currentViewState = DirectoryViewState.disconnected;
  String _selectedAccountTypeFilter = 'All';
  String _selectedStatusFilter = 'All';

  // Checking backend connection state
  bool _isCheckingConnection = false;

  @override
  void dispose() {
    _searchIdController.dispose();
    _filterTextController.dispose();
    super.dispose();
  }

  /// Handles search customer by ID
  Future<void> _performIdSearch() async {
    final query = _searchIdController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Customer ID to search (e.g. CUST-1001).'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    setState(() {
      _isSearchingId = true;
      _hasSearchedId = true;
      _lastSearchedQuery = query;
    });

    // Simulate network query attempt to backend
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    setState(() {
      _isSearchingId = false;
    });
  }

  void _clearIdSearch() {
    _searchIdController.clear();
    setState(() {
      _hasSearchedId = false;
      _lastSearchedQuery = '';
    });
  }

  /// Pings backend connection
  Future<void> _checkConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    final isConnected = await _customerService.checkBackendConnection();

    if (!mounted) return;
    setState(() {
      _isCheckingConnection = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle_rounded : Icons.cloud_off_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isConnected
                    ? 'Backend connected at ${CustomerService.baseUrl}'
                    : 'Backend is offline (${CustomerService.baseUrl}). Connect the backend service to view customer records.',
              ),
            ),
          ],
        ),
        backgroundColor: isConnected ? const Color(0xFF059669) : const Color(0xFFDC2626),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Filtered items strictly used when inspecting the responsive layout template preview
  List<Customer> get _filteredPreviewCustomers {
    final templates = CustomerService.getPreviewLayoutTemplates();
    return templates.where((c) {
      final matchesType = _selectedAccountTypeFilter == 'All' || c.accountType == _selectedAccountTypeFilter;
      final matchesStatus = _selectedStatusFilter == 'All' || c.accountStatus == _selectedStatusFilter;
      final query = _filterTextController.text.trim().toLowerCase();
      if (query.isEmpty) return matchesType && matchesStatus;

      final matchesQuery = c.fullName.toLowerCase().contains(query) ||
          c.customerId.toLowerCase().contains(query) ||
          c.accountNumber.contains(query) ||
          c.branchName.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          c.phone.contains(query);

      return matchesType && matchesStatus && matchesQuery;
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
              // SECTION 1: SEARCH CUSTOMER BY ID
              // ==========================================
              _buildSearchByIdSection(isDesktop),
              const SizedBox(height: 28),

              // ==========================================
              // SECTION 2: VIEW CUSTOMERS DIRECTORY
              // ==========================================
              _buildCustomersDirectorySection(isDesktop),
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
            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Customer Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Search institutional records by Customer ID or monitor backend account repository',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Check Connection Action
          OutlinedButton.icon(
            onPressed: _isCheckingConnection ? null : _checkConnection,
            icon: _isCheckingConnection
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white, size: 16),
            label: const Text('Check Connection', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION 1: SEARCH CUSTOMER BY ID
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
                  'Search Customer by ID',
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
              'Enter a unique Customer ID to search for matching records.',
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
                      hintText: 'Enter Customer ID (e.g. CUST-1001, CUST-2024)...',
                      prefixIcon: const Icon(Icons.fingerprint_rounded, size: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                  ),
                ),
              ],
            ),

            // Search Results Panel
            if (_hasSearchedId) ...[
              const SizedBox(height: 20),
              const Divider(color: AppTheme.cardBorder),
              const SizedBox(height: 16),
              _buildSearchDisconnectedNotice(_lastSearchedQuery),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDisconnectedNotice(String query) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_off_rounded, color: Color(0xFFD97706), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Backend Disconnected — Search Inactive',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unable to query records for Customer ID "$query" because the backend service is not connected yet. In compliance with security requirements, customer records are not stored or queried on the frontend.',
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _clearIdSearch,
                      icon: const Icon(Icons.close_rounded, size: 15),
                      label: const Text('Clear Query'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF92400E),
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _checkConnection,
                      icon: const Icon(Icons.refresh_rounded, size: 15),
                      label: const Text('Check Backend Connection'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.navyPrimary,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION 2: VIEW CUSTOMERS DIRECTORY
  // ==========================================================
  Widget _buildCustomersDirectorySection(bool isDesktop) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title & UI State Switcher
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.list_alt_rounded, color: AppTheme.navyPrimary, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'View Customers',
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
                        color: _currentViewState == DirectoryViewState.disconnected
                            ? const Color(0xFFFEE2E2)
                            : AppTheme.blueLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentViewState == DirectoryViewState.disconnected
                            ? 'Disconnected'
                            : (_currentViewState == DirectoryViewState.layoutPreview
                                ? 'Template Preview'
                                : _currentViewState.name.toUpperCase()),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _currentViewState == DirectoryViewState.disconnected
                              ? const Color(0xFFDC2626)
                              : AppTheme.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),

                // Interactive UI State Preview Toolbar
                // Allows evaluating all states (Disconnected, Loading, Empty, Error, Layout Preview)
                _buildStatePreviewToolbar(),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBorder),
            const SizedBox(height: 16),

            // Content corresponding to current state
            _buildDirectoryContent(isDesktop),
          ],
        ),
      ),
    );
  }

  /// State selector toolbar to preview all mandatory UI states
  Widget _buildStatePreviewToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'UI State:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
            ),
            _buildStateChip('Disconnected', DirectoryViewState.disconnected),
            _buildStateChip('Loading', DirectoryViewState.loading),
            _buildStateChip('Empty', DirectoryViewState.empty),
            _buildStateChip('Error', DirectoryViewState.error),
            _buildStateChip('Layout Preview', DirectoryViewState.layoutPreview),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip(String label, DirectoryViewState state) {
    final isSelected = _currentViewState == state;
    return InkWell(
      onTap: () {
        setState(() {
          _currentViewState = state;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryContent(bool isDesktop) {
    switch (_currentViewState) {
      case DirectoryViewState.disconnected:
        return _buildDisconnectedState();
      case DirectoryViewState.loading:
        return _buildLoadingState();
      case DirectoryViewState.empty:
        return _buildEmptyState();
      case DirectoryViewState.error:
        return _buildErrorState();
      case DirectoryViewState.layoutPreview:
        return _buildLayoutPreviewState(isDesktop);
    }
  }

  // ==========================================================
  // MANDATED STATE 1: BACKEND DISCONNECTED (DEFAULT)
  // Shows: "Customer data is not connected yet. Please connect the backend to view customer records."
  // ==========================================================
  Widget _buildDisconnectedState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECACA), width: 2),
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Customer data is not connected yet. Please connect the backend to view customer records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'To protect client privacy and ensure transactional integrity, customer records are never stored in the Flutter frontend (no in-memory lists, local storage, or cached data).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isCheckingConnection ? null : _checkConnection,
                  icon: _isCheckingConnection
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Check Backend Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onNavigateToAdd?.call();
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Go to Add Customer Form'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MANDATED STATE 2: LOADING STATE
  // ==========================================================
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: const Column(
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: AppTheme.navyPrimary),
          SizedBox(height: 20),
          Text(
            'Fetching customer records from backend API...',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Connecting to http://127.0.0.1:8000/api/customers/',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MANDATED STATE 3: EMPTY STATE
  // ==========================================================
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AppTheme.blueLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded, size: 44, color: AppTheme.blueAccent),
          ),
          const SizedBox(height: 18),
          const Text(
            'No Customer Records Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No customer records are currently registered on the server database.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              widget.onNavigateToAdd?.call();
            },
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Add First Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.navyPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MANDATED STATE 4: ERROR STATE
  // ==========================================================
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 40),
          const SizedBox(height: 12),
          const Text(
            'Connection Error: Failed to Reach Backend',
            style: TextStyle(
              color: Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'HTTP 503 Service Unavailable: Could not establish a connection to http://127.0.0.1:8000/api/customers/. Please check backend server status.',
            style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentViewState = DirectoryViewState.loading;
              });
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  setState(() {
                    _currentViewState = DirectoryViewState.disconnected;
                  });
                }
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MANDATED STATE 5: RESPONSIVE LIST / TABLE LAYOUT PREVIEW
  // Demonstrates the responsive customer list with all 13 fields
  // Clearly watermarked as template preview (not saved data)
  // ==========================================================
  Widget _buildLayoutPreviewState(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Watermark Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.design_services_outlined, color: AppTheme.blueAccent, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Component Layout Template Preview: Demonstrating responsive DataTable (desktop) and Customer Cards (mobile/tablet) displaying all 13 customer attributes. Not saved frontend data.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter Controls
        if (isDesktop)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _filterTextController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Filter by name, ID, account #, branch, phone...',
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
                  initialValue: _selectedAccountTypeFilter,
                  isDense: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: ['All', ...Customer.accountTypes].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type == 'All' ? 'All Account Types' : '$type Accounts', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedAccountTypeFilter = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatusFilter,
                  isDense: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.toggle_on_outlined, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: ['All', ...Customer.accountStatuses].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status == 'All' ? 'All Statuses' : '$status Status', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStatusFilter = val;
                      });
                    }
                  },
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              TextField(
                controller: _filterTextController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Filter by name, ID, account #, branch...',
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedAccountTypeFilter,
                      isDense: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.credit_card_outlined, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      items: ['All', ...Customer.accountTypes].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type == 'All' ? 'All Types' : type, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedAccountTypeFilter = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatusFilter,
                      isDense: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.toggle_on_outlined, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      items: ['All', ...Customer.accountStatuses].map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status == 'All' ? 'All Status' : status, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStatusFilter = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 16),

        // List / Table
        if (_filteredPreviewCustomers.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: const Text('No records match your filter criteria.', style: TextStyle(color: AppTheme.textSecondary)),
          )
        else if (isDesktop)
          _buildDesktopTable()
        else
          _buildMobileCards(),
      ],
    );
  }

  Widget _buildDesktopTable() {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
            constraints: const BoxConstraints(minWidth: 1050),
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              columns: const [
                DataColumn(label: Text('CUSTOMER ID')),
                DataColumn(label: Text('FULL NAME')),
                DataColumn(label: Text('ACCOUNT NUMBER')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('BRANCH')),
                DataColumn(label: Text('BALANCE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: _filteredPreviewCustomers.map((cust) {
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
                          cust.customerId,
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
                        cust.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        cust.accountNumber,
                        style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(StatusBadge(status: cust.accountType, isCompact: true)),
                    DataCell(Text(cust.branchName)),
                    DataCell(
                      Text(
                        currencyFormatter.format(cust.accountBalance),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                      ),
                    ),
                    DataCell(StatusBadge(status: cust.accountStatus, isCompact: true)),
                    DataCell(
                      TextButton.icon(
                        onPressed: () => CustomerDetailModal.show(context, cust),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View Dossier'),
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
      children: _filteredPreviewCustomers.map((cust) {
        return CustomerCard(customer: cust);
      }).toList(),
    );
  }
}
