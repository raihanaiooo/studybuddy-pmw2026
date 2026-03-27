import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tutor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';

/// Halaman profil & portofolio tutor detail, lengkap dengan rating & CTA booking
class TutorDetailScreen extends StatelessWidget {
  const TutorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TutorController>();

    return Obx(() {
      final tutor = ctrl.selectedTutor.value;
      if (tutor == null)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      return Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // App bar dengan foto/avatar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.blueDark,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: Get.back,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.blueLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tutor.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tutor.fullName,
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tutor.isOnline) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.onlineGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.onlineGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            tutor.university,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _stat(
                            '${tutor.rating}',
                            '★ Rating',
                            AppColors.primaryYellow,
                          ),
                          _divider(),
                          _stat(
                            '${tutor.totalSessions}',
                            'Sesi',
                            AppColors.primaryBlue,
                          ),
                          _divider(),
                          _stat(
                            '${tutor.totalReviews}',
                            'Ulasan',
                            AppColors.accentTeal,
                          ),
                          _divider(),
                          _stat('${tutor.gpa}', 'IPK', AppColors.onlineGreen),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tentang saya
                    Text('Tentang Saya', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    Text(tutor.bio, style: AppTextStyles.body),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tutor.subjects
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                s,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Rating summary
                    Text('⭐ Rating & Ulasan', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Obx(() {
                      final reviews = ctrl.tutorReviews;
                      if (reviews.isEmpty) {
                        return Text(
                          'Belum ada ulasan',
                          style: AppTextStyles.caption,
                        );
                      }
                      return Column(
                        children: reviews
                            .take(5)
                            .map(
                              (r) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            r.customerId[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Customer',
                                                style:
                                                    AppTextStyles.bodySemiBold,
                                              ),
                                              Text(
                                                r.subject,
                                                style: AppTextStyles.caption,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '★' * r.rating + '☆' * (5 - r.rating),
                                          style: TextStyle(
                                            color: AppColors.primaryYellow,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(r.comment, style: AppTextStyles.body),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }),
                    const SizedBox(height: 100), // space for CTA
                  ],
                ),
              ),
            ),
          ],
        ),

        // CTA sticky bottom
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          color: Colors.white,
          child: Row(
            children: [
              // Chat button
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Booking button
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.booking, arguments: tutor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '📅 Booking Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'mulai dari Rp${(tutor.pricePerHour / 1000).toStringAsFixed(0)}rb/jam',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _stat(String value, String label, Color color) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.label),
    ],
  );

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.border);
}
