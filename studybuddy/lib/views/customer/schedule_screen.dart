import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../app/routes.dart';
import '../shared/widgets/status_badge.dart';

/// Screen jadwal booking customer
class CustomerScheduleScreen extends StatelessWidget {
  const CustomerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Jadwal Saya',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }
        if (ctrl.myBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📅', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Belum ada jadwal', style: AppTextStyles.heading3),
                const SizedBox(height: 6),
                Text(
                  'Booking tutor untuk mulai belajar!',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.myBookings.length,
          itemBuilder: (_, i) {
            final b = ctrl.myBookings[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                        child: Text(b.subject, style: AppTextStyles.heading3),
                      ),
                      StatusBadge(status: b.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppDateUtils.formatDateTime(b.sessionTime),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${b.durationMinutes} menit',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      if (b.status == 'confirmed')
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.session, arguments: b),
                          child: const Text(
                            'Mulai Sesi',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
