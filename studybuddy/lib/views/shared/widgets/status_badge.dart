import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Badge status booking: pending, confirmed, ongoing, done, cancelled
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.label.copyWith(color: config.color),
      ),
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig(AppColors.primaryYellow, 'Menunggu');
      case 'confirmed':
        return _StatusConfig(AppColors.primaryBlue, 'Dikonfirmasi');
      case 'ongoing':
        return _StatusConfig(AppColors.onlineGreen, 'Berlangsung');
      case 'done':
        return _StatusConfig(AppColors.accentTeal, 'Selesai');
      case 'cancelled':
        return _StatusConfig(AppColors.primaryRed, 'Dibatalkan');
      default:
        return _StatusConfig(AppColors.textLight, status);
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  const _StatusConfig(this.color, this.label);
}
