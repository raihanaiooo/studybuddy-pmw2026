import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/package_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/token_model.dart';

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
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }
        if (ctrl.myTokens.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎟️', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('Belum ada token', style: AppTextStyles.heading3),
                  const SizedBox(height: 6),
                  Text(
                    'Beli paket belajar untuk mendapatkan token sesi.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.fetchMyTokens,
          color: AppColors.primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ctrl.myTokens.length,
            itemBuilder: (_, i) {
              final token = ctrl.myTokens[i];
              final pkg = ctrl.packageById(token.packageId);
              return _tokenCard(
                token,
                pkg?.name ?? 'Paket',
                pkg?.rescheduleQuota ?? 0,
              );
            },
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          const SizedBox(height: 10),
          // Sisa sesi — penting!
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: token.sessionsRemaining > 0
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : AppColors.textLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 14,
                  color: token.sessionsRemaining > 0
                      ? AppColors.primaryBlue
                      : AppColors.textLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sisa ${token.sessionsRemaining} sesi',
                  style: AppTextStyles.caption.copyWith(
                    color: token.sessionsRemaining > 0
                        ? AppColors.primaryBlue
                        : AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Berlaku s.d. ${DateFormat('dd MMM yyyy').format(token.expiryDate)}',
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
          if (rescheduleQuota > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Kuota reschedule: $rescheduleQuota',
              style: AppTextStyles.caption,
            ),
          ],
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
