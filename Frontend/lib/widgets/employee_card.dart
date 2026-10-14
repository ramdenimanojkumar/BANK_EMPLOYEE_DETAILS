import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import 'employee_detail_modal.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  const EmployeeCard({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: () => EmployeeDetailModal.show(context, employee),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: ID Badge & Status
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
                      employee.id,
                      style: const TextStyle(
                        color: AppTheme.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  StatusBadge(status: employee.employmentStatus, isCompact: true),
                ],
              ),
              const SizedBox(height: 10),

              // Name & Designation
              Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                employee.designation,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.blueAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.cardBorder, height: 1),
              const SizedBox(height: 12),

              // Department & Branch
              _buildInfoRow(Icons.corporate_fare_rounded, 'Dept:', employee.department),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.location_on_outlined, 'Branch:', employee.branchName),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.phone_outlined, 'Phone:', employee.phone),

              const SizedBox(height: 12),
              // Bottom Action Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => EmployeeDetailModal.show(context, employee),
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
