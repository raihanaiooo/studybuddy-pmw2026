import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Badge status verifikasi dokumen Tutor (FR-PROF-09)
class VerificationBadge extends StatelessWidget {
  final String status;

  const VerificationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AppTextStyles.label.copyWith(color: config.color),
          ),
        ],
      ),
    );
  }

  _VerificationConfig _config(String status) {
    switch (status) {
      case 'verified':
      case 'terverifikasi':
        return _VerificationConfig(
          AppColors.onlineGreen,
          'Terverifikasi',
          Icons.check_circle_outline,
        );
      case 'rejected':
      case 'ditolak':
        return _VerificationConfig(
          AppColors.primaryRed,
          'Ditolak',
          Icons.cancel_outlined,
        );
      case 'menunggu':
        return _VerificationConfig(
          AppColors.primaryYellow,
          'Menunggu Verifikasi',
          Icons.hourglass_empty,
        );
      case 'belum_upload':
        return _VerificationConfig(
          AppColors.textLight,
          'Belum Upload',
          Icons.upload_file_outlined,
        );
      default:
        return _VerificationConfig(
          AppColors.primaryYellow,
          'Menunggu Verifikasi',
          Icons.hourglass_empty,
        );
    }
  }
}

class _VerificationConfig {
  final Color color;
  final String label;
  final IconData icon;
  const _VerificationConfig(this.color, this.label, this.icon);
}
