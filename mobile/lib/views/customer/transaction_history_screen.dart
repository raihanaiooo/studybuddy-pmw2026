import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../models/invoice_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../shared/widgets/invoice_status_badge.dart';

/// Riwayat transaksi pembayaran Buddy (FR-PAY-14) + ajukan refund untuk
/// transaksi Lunas (FR-PAY-09/10)
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PaymentController>();

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
          'Riwayat Transaksi',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧾', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada transaksi',
                    style: AppTextStyles.bodySemiBold,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transaksi kamu akan muncul di sini.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.fetchHistory,
          color: AppColors.primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ctrl.history.length,
            itemBuilder: (_, i) =>
                _transactionCard(context, ctrl, ctrl.history[i]),
          ),
        );
      }),
    );
  }

  Widget _transactionCard(
    BuildContext context,
    PaymentController ctrl,
    InvoiceModel inv,
  ) {
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
                child: Text(
                  inv.sessions.map((s) => s.subject).join(', '),
                  style: AppTextStyles.bodySemiBold,
                ),
              ),
              InvoiceStatusBadge(status: inv.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('Sesi dengan ${inv.tutorName}', style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            AppDateUtils.formatDate(inv.createdAt),
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Rp${CurrencyUtils.formatPrice(inv.total)}',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              const Spacer(),
              if (inv.status == InvoiceStatus.paid)
                TextButton(
                  onPressed: () => _openRefundSheet(context, ctrl, inv),
                  child: const Text(
                    'Ajukan Refund',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openRefundSheet(
    BuildContext context,
    PaymentController ctrl,
    InvoiceModel inv,
  ) {
    const reasons = [
      'Berubah pikiran',
      'Jadwal bentrok',
      'Salah pilih Tutor',
      'Lainnya',
    ];
    String selected = reasons.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ajukan Refund', style: AppTextStyles.heading2),
                const SizedBox(height: 6),
                Text(inv.id, style: AppTextStyles.caption),
                const SizedBox(height: 16),
                Text('Alasan Pembatalan', style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons
                      .map(
                        (r) => ChoiceChip(
                          label: Text(r),
                          selected: selected == r,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: selected == r
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => setSheetState(() => selected = r),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => ctrl.requestRefund(inv.id, selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ajukan Refund',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
