import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../models/invoice_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../shared/widgets/invoice_status_badge.dart';

/// Invoice pembayaran QRIS Dynamic (FR-PAY-01..08)
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Invoice Pembayaran',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Obx(() {
        final inv = ctrl.invoice.value;
        if (inv == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧾', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada invoice aktif',
                    style: AppTextStyles.bodySemiBold,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Silakan buat booking terlebih dahulu.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          );
        }

        if (inv.status == InvoiceStatus.paid) return _paidState(inv);
        if (inv.status == InvoiceStatus.expired) {
          return _expiredState(context, ctrl, inv);
        }

        return _waitingState(context, ctrl, inv);
      }),
    );
  }

  Widget _waitingState(
    BuildContext context,
    PaymentController ctrl,
    InvoiceModel inv,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _invoiceHeaderCard(inv),
        const SizedBox(height: 16),
        _sessionDetailCard(inv),
        const SizedBox(height: 16),
        _costBreakdownCard(inv),
        const SizedBox(height: 20),
        _qrCard(ctrl),
        const SizedBox(height: 20),
        _howToPayCard(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Obx(
            () => ElevatedButton(
              onPressed: ctrl.isCheckingStatus.value
                  ? null
                  : ctrl.checkPaymentStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: ctrl.isCheckingStatus.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : const Text(
                      'Cek Status Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => _confirmCancel(context, ctrl),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryRed),
            ),
            child: const Text(
              'Batalkan Pesanan',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _invoiceHeaderCard(InvoiceModel inv) => Container(
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
                inv.id,
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            InvoiceStatusBadge(status: inv.status),
          ],
        ),
        const SizedBox(height: 10),
        Text('Nama Murid', style: AppTextStyles.caption),
        Text(inv.studentName, style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 6),
        Text(
          '${inv.studentGrade} · ${inv.studentSchool}',
          style: AppTextStyles.caption,
        ),
      ],
    ),
  );

  Widget _sessionDetailCard(InvoiceModel inv) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.06),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detail Sesi', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        Text('Tutor: ${inv.tutorName}', style: AppTextStyles.body),
        const SizedBox(height: 10),
        ...inv.sessions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(s.subject, style: AppTextStyles.bodySemiBold),
                ),
                Text(
                  '${AppDateUtils.formatDate(s.sessionDate)} · ${s.startTime}-${s.endTime}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _costBreakdownCard(InvoiceModel inv) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.06),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rincian Biaya', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        _costRow('Subtotal (${inv.sessions.length} sesi)', inv.subtotal),
        if (inv.discount > 0) _costRow('Diskon', -inv.discount),
        const Divider(height: 20),
        _costRow('Total Tagihan', inv.total, emphasize: true),
      ],
    ),
  );

  Widget _costRow(
    String label,
    double value, {
    bool emphasize = false,
  }) => Padding(
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
          'Rp${CurrencyUtils.formatPrice(value.abs())}',
          style: emphasize
              ? AppTextStyles.heading3.copyWith(color: AppColors.primaryBlue)
              : AppTextStyles.body,
        ),
      ],
    ),
  );

  Widget _qrCard(PaymentController ctrl) => Container(
    padding: const EdgeInsets.all(20),
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
      children: [
        Text(
          'Scan QRIS Dynamic (ShopeePay)',
          style: AppTextStyles.bodySemiBold,
        ),
        const SizedBox(height: 4),
        Text(
          'Bisa dibayar via GoPay, OVO, BCA, ShopeePay, Livin, dsb.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _QrPlaceholder(),
        const SizedBox(height: 16),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppColors.primaryRed,
              ),
              const SizedBox(width: 6),
              Text(
                'Selesaikan sebelum ${ctrl.remainingLabel}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () =>
              Get.snackbar('Tersimpan', 'QR berhasil disimpan ke galeri'),
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Simpan / Unduh QR'),
        ),
      ],
    ),
  );

  Widget _howToPayCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryBlue.withOpacity(0.06),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cara Bayar', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 8),
        _stepRow('1', 'Buka aplikasi m-banking / e-wallet favoritmu'),
        _stepRow('2', 'Pilih menu Scan QRIS, arahkan ke kode di atas'),
        _stepRow('3', 'Periksa nominal, lalu konfirmasi pembayaran'),
      ],
    ),
  );

  Widget _stepRow(String number, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.caption)),
      ],
    ),
  );

  Widget _paidState(InvoiceModel inv) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.onlineGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle,
              color: AppColors.onlineGreen,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text('Pembayaran Berhasil!', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Link Google Meet sudah otomatis terpasang di booking kamu.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            inv.id,
            style: AppTextStyles.caption.copyWith(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Lihat Booking Saya',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _expiredState(
    BuildContext context,
    PaymentController ctrl,
    InvoiceModel inv,
  ) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.timer_off_outlined,
              color: AppColors.primaryRed,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text('Invoice Kedaluwarsa', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Waktu pembayaran sudah habis. Slot jadwal sudah dibuka kembali untuk Buddy lain.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _confirmCancel(BuildContext context, PaymentController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Slot jadwal akan dibuka kembali untuk Buddy lain.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Tidak')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            onPressed: ctrl.cancelOrder,
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

/// Placeholder visual QR — tanpa dependency generator QR sungguhan,
/// cukup untuk kebutuhan UI scaffolding.
class _QrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.qr_code_2,
        size: 140,
        color: AppColors.textPrimary,
      ),
    );
  }
}
