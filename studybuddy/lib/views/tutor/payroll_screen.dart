import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payroll_controller.dart';
import '../../models/payroll_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';

/// Ringkasan honor Tutor: saldo belum dibayar & riwayat pembayaran
/// (FR-PAYR-01, FR-PAYR-03, FR-PAYR-07)
class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PayrollController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Honor Saya',
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
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _balanceCard(ctrl),
            const SizedBox(height: 24),
            Text('Riwayat Slip Gaji', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            ...ctrl.records.map((r) => _recordTile(r)),
          ],
        );
      }),
    );
  }

  Widget _balanceCard(PayrollController ctrl) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: AppColors.headerGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 16),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo Belum Dibayar',
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          'Rp${_formatPrice(ctrl.pendingBalance)}',
          style: AppTextStyles.heading1.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Dicairkan otomatis setiap akhir bulan',
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    ),
  );

  Widget _recordTile(PayrollRecordModel record) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 8),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.period, style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 4),
              Text(
                '${record.sessions.length} sesi · Rp${_formatPrice(record.totalHakTutor)}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 6),
              _PayrollStatusBadge(status: record.status),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.slipGaji, arguments: record),
          child: const Text(
            'Lihat Slip',
            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}

class _PayrollStatusBadge extends StatelessWidget {
  final PayrollStatus status;
  const _PayrollStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final paid = status == PayrollStatus.sudahDibayar;
    final color = paid ? AppColors.onlineGreen : AppColors.primaryYellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        paid ? 'Sudah Dibayar' : 'Belum Dibayar',
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}
