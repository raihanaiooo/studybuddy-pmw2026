import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../app/routes.dart';
import '../shared/widgets/customer_scaffold.dart';
import '../shared/widgets/status_badge.dart';

class CustomerScheduleScreen extends StatelessWidget {
  const CustomerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingController>();

    return CustomerScaffold(
      currentIndex: 2,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Booking Kamu',
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
                Text('Belum ada booking', style: AppTextStyles.heading3),
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
          itemBuilder: (_, i) =>
              _bookingCard(context, ctrl, ctrl.myBookings[i]),
        );
      }),
    );
  }

  Widget _bookingCard(BuildContext context, BookingController ctrl, dynamic b) {
    final canCancel = b.status == 'pending' || b.status == 'confirmed';
    final canReschedule = b.status == 'confirmed';
    final canStartSession =
        b.status == 'confirmed' && _isSessionReadyToStart(b.sessionTime);

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
              Expanded(child: Text(b.subject, style: AppTextStyles.heading3)),
              StatusBadge(status: b.status),
            ],
          ),
          const SizedBox(height: 12),
          if (b.tutorFullName != null && b.tutorFullName!.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.blueLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    b.tutorFullName![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b.tutorFullName!,
                    style: AppTextStyles.bodySemiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
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
              Text('${b.durationMinutes} menit', style: AppTextStyles.caption),
            ],
          ),
          if (b.notes != null && b.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan: ${b.notes}',
              style: AppTextStyles.caption.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (canCancel || canReschedule || canStartSession) ...[
            const SizedBox(height: 8),
            const Divider(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              children: [
                if (canReschedule)
                  TextButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.reschedule, arguments: b),
                    icon: const Icon(
                      Icons.edit_calendar_outlined,
                      size: 16,
                      color: AppColors.accentTeal,
                    ),
                    label: const Text(
                      'Reschedule',
                      style: TextStyle(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (canCancel)
                  TextButton(
                    onPressed: () => _confirmCancel(context, ctrl, b.id),
                    child: const Text(
                      'Batalkan',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (canStartSession)
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
        ],
      ),
    );
  }

  bool _isSessionReadyToStart(DateTime sessionTime) {
    final now = DateTime.now();
    final diff = sessionTime.difference(now);
    return !diff.isNegative && diff.inMinutes <= 15;
  }

  void _confirmCancel(
    BuildContext context,
    BookingController ctrl,
    String bookingId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Booking?'),
        content: const Text(
          'Booking akan dibatalkan. Kebijakan refund akan mengikuti aturan yang berlaku.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Tidak')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              ctrl.cancelBooking(bookingId);
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
