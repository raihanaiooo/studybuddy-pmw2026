import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/package_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/package_model.dart';
import '../../models/invoice_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';
import '../shared/widgets/package_card.dart';

/// Katalog Paket & Token belajar (FR-PKG-01)
class PackageScreen extends StatelessWidget {
  const PackageScreen({super.key});

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
          'Paket & Token',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.myTokens),
            child: const Text(
              'Token Saya',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }
        if (ctrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    ctrl.errorMessage.value,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: ctrl.fetchPackages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        if (ctrl.packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📦', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'Belum ada paket tersedia',
                  style: AppTextStyles.bodySemiBold,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.fetchPackages,
          color: AppColors.primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ctrl.packages.length,
            itemBuilder: (_, i) {
              final pkg = ctrl.packages[i];
              return PackageCard(
                package: pkg,
                onBuy: () => _confirmPurchase(context, pkg),
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmPurchase(BuildContext context, PackageModel package) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pembelian'),
        content: Text(
          'Lanjutkan pembelian "${package.name}"? Kamu akan diarahkan ke halaman pembayaran QRIS.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              _goToInvoice(package);
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _goToInvoice(PackageModel package) {
    final auth = Get.find<AuthController>();
    final packageCtrl = Get.find<PackageController>();
    final paymentCtrl = Get.find<PaymentController>();
    final user = auth.currentUser.value;
    final now = DateTime.now();

    paymentCtrl.generateInvoice(
      tutorName: '-', // pembelian paket, belum terikat ke Tutor tertentu
      studentName: user?.fullName ?? 'Buddy',
      studentGrade: user?.jenjang ?? '-',
      studentSchool: '-',
      sessions: [
        InvoiceSessionItem(
          subject: package.name,
          sessionDate: now,
          startTime: '-',
          endTime: '-',
          price: package.price,
        ),
      ],
      onPaid: () => packageCtrl.grantToken(package),
    );

    Get.toNamed(AppRoutes.invoice);
  }
}
