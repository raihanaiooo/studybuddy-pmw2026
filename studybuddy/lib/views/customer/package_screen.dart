import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/package_controller.dart';
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ctrl.packages.length,
          itemBuilder: (_, i) {
            final pkg = ctrl.packages[i];
            return PackageCard(
              package: pkg,
              onBuy: () => _confirmPurchase(context, pkg.name),
            );
          },
        );
      }),
    );
  }

  void _confirmPurchase(BuildContext context, String packageName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pembelian'),
        content: Text(
          'Lanjutkan pembelian "$packageName"? Kamu akan diarahkan ke halaman pembayaran QRIS.',
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
              Get.snackbar(
                'Segera Hadir',
                'Halaman pembayaran (Sprint 3) belum tersedia.',
              );
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }
}
