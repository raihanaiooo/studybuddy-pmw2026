import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/package_model.dart';

/// Card katalog paket/bundling untuk daftar Paket & Token (FR-PKG-01)
class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onBuy;

  const PackageCard({super.key, required this.package, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(package.name, style: AppTextStyles.heading3),
              ),
              if (!package.isRefundable)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Non-Refundable',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(package.description, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                Icons.confirmation_number_outlined,
                '${package.sessionCount} sesi',
              ),
              _infoChip(
                Icons.event_outlined,
                '${package.validityDays} hari',
              ),
              if (package.rescheduleQuota > 0)
                _infoChip(
                  Icons.sync_outlined,
                  '${package.rescheduleQuota}x reschedule',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Rp${_formatPrice(package.price)}',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Beli',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  Widget _infoChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    ),
  );
}
