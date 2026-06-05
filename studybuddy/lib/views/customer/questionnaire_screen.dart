import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer/questionnaire_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/widgets/tutor_card.dart';

/// Screen kuesioner untuk rekomendasi tutor
class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuestionnaireController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Rekomendasi Tutor',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temukan Tutor Ideal',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Isi kuesioner berikut untuk mendapatkan rekomendasi tutor yang sesuai kebutuhanmu',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mata Kuliah
            _buildSectionTitle('📚 Mata Kuliah yang Dibutuhkan'),
            const SizedBox(height: 10),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.subjects.map((s) {
                final selected = ctrl.selectedSubject.value == s;
                return GestureDetector(
                  onTap: () => ctrl.selectSubject(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 24),

            // Tujuan Belajar
            _buildSectionTitle('🎯 Tujuan Belajar'),
            const SizedBox(height: 10),
            Obx(() => Column(
              children: ctrl.goals.map((g) {
                final selected = ctrl.selectedGoal.value == g;
                return GestureDetector(
                  onTap: () => ctrl.selectGoal(g),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.textLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          g,
                          style: AppTextStyles.bodySemiBold.copyWith(
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 24),

            // Level Kemampuan
            _buildSectionTitle('📊 Level Kemampuan'),
            const SizedBox(height: 10),
            Obx(() => Row(
              children: ctrl.levels.map((l) {
                final selected = ctrl.selectedLevel.value == l;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.selectLevel(l),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: l != ctrl.levels.last ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l == 'Dasar'
                                ? '🌱'
                                : l == 'Menengah'
                                    ? '📘'
                                    : '🚀',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l,
                            style: AppTextStyles.bodySemiBold.copyWith(
                              color:
                                  selected ? Colors.white : AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ctrl.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cari Tutor yang Cocok',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recommended Tutors
            Obx(() {
              if (!ctrl.hasSubmitted.value || ctrl.recommendedTutors.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⭐ Tutor yang Cocok untuk Kamu',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ctrl.recommendedTutors.length} tutor ditemukan',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  ...ctrl.recommendedTutors.map(
                    (tutor) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TutorCard(
                        tutor: tutor,
                        compact: false,
                        onTap: () => ctrl.goToRecommendedTutor(tutor),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(fontFamily: 'Poppins'),
    );
  }
}
