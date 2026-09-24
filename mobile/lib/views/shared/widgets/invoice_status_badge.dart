import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/invoice_model.dart';

/// Badge status invoice (FR-PAY-05) — dipakai bersama oleh InvoiceScreen
/// dan TransactionHistoryScreen supaya label/warna tidak divergen.
class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  const InvoiceStatusBadge({super.key, required this.status});

  static (Color, String) configFor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.waiting:
        return (AppColors.primaryYellow, 'Menunggu Pembayaran');
      case InvoiceStatus.paid:
        return (AppColors.onlineGreen, 'Lunas');
      case InvoiceStatus.expired:
        return (AppColors.textLight, 'Kedaluwarsa');
      case InvoiceStatus.cancelled:
        return (AppColors.primaryRed, 'Dibatalkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = configFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
    );
  }
}
