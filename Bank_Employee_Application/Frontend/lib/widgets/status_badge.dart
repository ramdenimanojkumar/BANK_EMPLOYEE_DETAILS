import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.trim().toLowerCase()) {
      case 'active':
        bg = AppTheme.statusActiveBg;
        fg = AppTheme.statusActive;
        break;
      case 'inactive':
        bg = AppTheme.statusInactiveBg;
        fg = AppTheme.statusInactive;
        break;
      case 'savings':
        bg = AppTheme.accountSavingsBg;
        fg = AppTheme.accountSavings;
        break;
      case 'current':
        bg = AppTheme.accountCurrentBg;
        fg = AppTheme.accountCurrent;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
