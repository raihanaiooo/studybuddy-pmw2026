import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/package_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/token_model.dart';

/// Riwayat & status token belajar milik Buddy (FR-PKG-03, FR-PKG-06)
class MyTokensScreen extends StatelessWidget {
  const MyTokensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PackageController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
        title: Text(
          'Token Saya',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.myTokens.isEmpty) {
          return Center(
            child: Text('Belum ada token aktif', style: AppTextStyles.caption),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ctrl.myTokens.length,
          itemBuilder: (_, i) {
            final token = ctrl.myTokens[i];
            final pkg = ctrl.packageById(token.packageId);
            return _tokenCard(token, pkg?.name ?? 'Paket', pkg?.rescheduleQuota ?? 0);
          },
        );
      }),
    );
  }

  Widget _tokenCard(TokenModel token, String packageName, int rescheduleQuota) {
    final config = _statusConfig(token.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(packageName, style: AppTextStyles.bodySemiBold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  config.label,
                  style: AppTextStyles.label.copyWith(color: config.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Berlaku s.d. ${DateFormat('dd MMM yyyy', 'id').format(token.expiryDate)}',
            style: AppTextStyles.caption,
          ),
          if (token.status == 'active') ...[
            const SizedBox(height: 2),
            Text(
              token.daysLeft >= 0
                  ? '${token.daysLeft} hari tersisa'
                  : 'Kedaluwarsa',
              style: AppTextStyles.caption.copyWith(
                color: token.daysLeft <= 2
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text('Kuota reschedule: $rescheduleQuota', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  _TokenStatusConfig _statusConfig(String status) {
    switch (status) {
      case 'active':
        return _TokenStatusConfig(AppColors.onlineGreen, 'Aktif');
      case 'used':
        return _TokenStatusConfig(AppColors.accentTeal, 'Terpakai');
      case 'expired':
        return _TokenStatusConfig(AppColors.textLight, 'Hangus');
      default:
        return _TokenStatusConfig(AppColors.textLight, status);
    }
  }
}

class _TokenStatusConfig {
  final Color color;
  final String label;
  const _TokenStatusConfig(this.color, this.label);
}
