import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import 'customer_detail_modal.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: () => CustomerDetailModal.show(context, customer),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: ID Badge & Status Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.blueLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      customer.customerId,
                      style: const TextStyle(
                        color: AppTheme.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(status: customer.accountType, isCompact: true),
                      const SizedBox(width: 6),
                      StatusBadge(status: customer.accountStatus, isCompact: true),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Name & Account Number
              Text(
                customer.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'A/C: ${customer.accountNumber} • ${customer.accountType}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.blueAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.cardBorder, height: 1),
              const SizedBox(height: 12),

              // Info rows
              _buildInfoRow(Icons.location_city_rounded, 'Branch:', '${customer.branchName} (${customer.branchCode})'),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.phone_outlined, 'Phone:', customer.phone),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.account_balance_wallet_outlined, 'Balance:', currencyFormatter.format(customer.accountBalance)),

              const SizedBox(height: 12),
              // Bottom Action Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => CustomerDetailModal.show(context, customer),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Full Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.navyPrimary,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
