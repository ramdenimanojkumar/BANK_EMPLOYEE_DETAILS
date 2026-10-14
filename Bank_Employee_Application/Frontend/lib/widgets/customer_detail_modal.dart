import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class CustomerDetailModal extends StatelessWidget {
  final Customer customer;

  const CustomerDetailModal({
    super.key,
    required this.customer,
  });

  static void show(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => CustomerDetailModal(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMMM dd, yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: AppTheme.navyPrimary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      child: Text(
                        customer.fullName.isNotEmpty
                            ? customer.fullName.substring(0, 1).toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  customer.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              StatusBadge(status: customer.accountStatus, isCompact: true),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${customer.accountType} Account • #${customer.accountNumber}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // Body Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System ID banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.blueLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.blueAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_rounded, color: AppTheme.blueAccent, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            'Customer ID:',
                            style: TextStyle(
                              color: AppTheme.navyPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customer.customerId,
                            style: const TextStyle(
                              color: AppTheme.blueAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          StatusBadge(status: customer.accountType, isCompact: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1: Personal & Contact Information
                    _buildSectionHeader('Personal & Contact Information', Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'Date of Birth',
                            dateFormatter.format(customer.dateOfBirth),
                            Icons.cake_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailTile(
                            'Phone Number',
                            customer.phone,
                            Icons.phone_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailTile(
                      'Email Address',
                      customer.email,
                      Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailTile(
                      'Residential Address',
                      customer.address,
                      Icons.home_outlined,
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.cardBorder),
                    const SizedBox(height: 16),

                    // Section 2: Banking & Account Details
                    _buildSectionHeader('Bank Account & Branch Details', Icons.account_balance_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'Account Number',
                            customer.accountNumber,
                            Icons.pin_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailTile(
                            'Account Type',
                            customer.accountType,
                            Icons.credit_card_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'Branch Name',
                            customer.branchName,
                            Icons.location_city_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailTile(
                            'Branch Code',
                            customer.branchCode,
                            Icons.numbers_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'Account Opening Date',
                            dateFormatter.format(customer.accountOpeningDate),
                            Icons.calendar_month_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailTile(
                            'Account Balance',
                            currencyFormatter.format(customer.accountBalance),
                            Icons.account_balance_wallet_outlined,
                            highlightValue: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close Dossier'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.navyPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.navyPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(
    String label,
    String value,
    IconData icon, {
    bool highlightValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlightValue ? FontWeight.w700 : FontWeight.w600,
                    color: highlightValue ? const Color(0xFF047857) : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
