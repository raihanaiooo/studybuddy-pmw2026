import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tutor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';
import '../shared/widgets/tutor_card.dart';

/// Screen daftar & pencarian tutor dengan filter online/semua
class TutorListScreen extends StatelessWidget {
  const TutorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TutorController>();
    final onlineOnly =
        (Get.arguments as Map<String, dynamic>?)?['onlineOnly'] as bool? ??
        false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          onlineOnly ? '⚡ Tutor Online' : 'Cari Tutor',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => ctrl.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Cari tutor atau mata kuliah...',
                hintStyle: AppTextStyles.caption,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textLight,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = onlineOnly
                  ? ctrl.filtered.where((t) => t.isOnline).toList()
                  : ctrl.filtered;
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada tutor ditemukan',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => TutorCard(
                  tutor: list[i],
                  onTap: () {
                    ctrl.selectTutor(list[i]);
                    Get.toNamed(AppRoutes.tutorDetail);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
