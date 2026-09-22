import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/payroll_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';

/// Slip Gaji Tutor per periode (FR-PAYR-06)
class SlipGajiScreen extends StatelessWidget {
  const SlipGajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final record = Get.arguments as PayrollRecordModel;

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
          'Slip Gaji',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Unduh Slip',
            onPressed: () => Get.snackbar('Diunduh', 'Slip gaji disimpan ke perangkat'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _headerCard(record),
          const SizedBox(height: 16),
          _sessionTable(record),
          const SizedBox(height: 16),
          _summaryCard(record),
        ],
      ),
    );
  }

  Widget _headerCard(PayrollRecordModel record) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nama Tutor', style: AppTextStyles.caption),
        Text(record.tutorName, style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 10),
        Text('Periode', style: AppTextStyles.caption),
        Text(record.period, style: AppTextStyles.bodySemiBold),
      ],
    ),
  );

  Widget _sessionTable(PayrollRecordModel record) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.06), blurRadius: 6),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rincian Sesi', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        ...record.sessions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(s.material, style: AppTextStyles.bodySemiBold),
                    ),
                    Text(
                      'Rp${_formatPrice(s.hakTutor)}',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppDateUtils.formatDate(s.classDate)} · ${s.buddyName} · '
                  '${s.sessionCount}x Rp${_formatPrice(s.ratePerSession)}',
                  style: AppTextStyles.caption,
                ),
                if (s.deduction > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Potongan Rp${_formatPrice(s.deduction)}'
                      '${s.deductionNote != null ? ' — ${s.deductionNote}' : ''}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryRed),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _summaryCard(PayrollRecordModel record) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.06), blurRadius: 6),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rekonsiliasi', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        _row('Total Hak Tutor', record.totalHakTutor),
        _row('Total Sudah Ditransfer', record.totalTransferred),
        const Divider(height: 20),
        _row(
          record.remainingBalance > 0 ? 'Sisa Kurang Bayar' : 'Lunas',
          record.remainingBalance,
          emphasize: true,
        ),
        if (record.transferDate != null) ...[
          const SizedBox(height: 10),
          Text(
            'Ditransfer pada ${AppDateUtils.formatDate(record.transferDate!)}',
            style: AppTextStyles.caption,
          ),
        ],
      ],
    ),
  );

  Widget _row(String label, double value, {bool emphasize = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize ? AppTextStyles.bodySemiBold : AppTextStyles.body,
          ),
        ),
        Text(
          'Rp${_formatPrice(value.abs())}',
          style: emphasize
              ? AppTextStyles.heading3.copyWith(color: AppColors.primaryBlue)
              : AppTextStyles.body,
        ),
      ],
    ),
  );

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}
