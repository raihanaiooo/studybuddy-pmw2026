import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/tutor_schedule_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../shared/widgets/status_badge.dart';

/// Jadwal Tutor: sesi terjadwal (booking) & pengaturan slot ketersediaan
/// sendiri (FR-BOOK-01, FR-BOOK-07)
class TutorScheduleScreen extends StatelessWidget {
  const TutorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.blueDark,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Jadwal Saya',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Sesi Terjadwal'),
              Tab(text: 'Atur Ketersediaan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ScheduledSessionsTab(), _AvailabilityTab()],
        ),
      ),
    );
  }
}

class _ScheduledSessionsTab extends StatelessWidget {
  const _ScheduledSessionsTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        );
      }
      if (ctrl.tutorBookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Belum ada sesi terjadwal', style: AppTextStyles.heading3),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.tutorBookings.length,
        itemBuilder: (_, i) {
          final b = ctrl.tutorBookings[i];
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
              ],
            ),
          );
        },
      );
    });
  }
}

class _AvailabilityTab extends StatelessWidget {
  const _AvailabilityTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TutorScheduleController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSlotSheet(context, ctrl),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Slot'),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }
        if (ctrl.slots.isEmpty) {
          return Center(
            child: Text(
              'Belum ada slot ketersediaan.\nTambah slot supaya Buddy bisa booking kamu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: ctrl.slots.length,
          itemBuilder: (_, i) {
            final slot = ctrl.slots[i];
            final booked = slot.status == 'booked';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: (booked ? AppColors.textLight : AppColors.onlineGreen)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.access_time,
                      size: 18,
                      color: booked ? AppColors.textLight : AppColors.onlineGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatDate(slot.startTime),
                          style: AppTextStyles.bodySemiBold,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppDateUtils.formatTime(slot.startTime)} - '
                          '${AppDateUtils.formatTime(slot.endTime)} ${slot.timezone}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (booked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Dibooking',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.primaryRed,
                      ),
                      onPressed: () => ctrl.removeSlot(slot.id),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _openAddSlotSheet(BuildContext context, TutorScheduleController ctrl) {
    DateTime? date;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                Text('Tambah Slot Ketersediaan', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                _pickerTile(
                  icon: Icons.calendar_today_outlined,
                  label: date == null
                      ? 'Pilih tanggal'
                      : AppDateUtils.formatDate(date!),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: now.add(const Duration(days: 1)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 60)),
                    );
                    if (picked != null) setSheetState(() => date = picked);
                  },
                ),
                const SizedBox(height: 12),
                _pickerTile(
                  icon: Icons.access_time,
                  label: startTime == null
                      ? 'Jam mulai'
                      : startTime!.format(ctx),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) setSheetState(() => startTime = picked);
                  },
                ),
                const SizedBox(height: 12),
                _pickerTile(
                  icon: Icons.access_time_filled,
                  label: endTime == null ? 'Jam selesai' : endTime!.format(ctx),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (picked != null) setSheetState(() => endTime = picked);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (date == null || startTime == null || endTime == null) {
                        Get.snackbar('Perhatian', 'Lengkapi tanggal & jam dulu');
                        return;
                      }
                      final start = DateTime(
                        date!.year,
                        date!.month,
                        date!.day,
                        startTime!.hour,
                        startTime!.minute,
                      );
                      final end = DateTime(
                        date!.year,
                        date!.month,
                        date!.day,
                        endTime!.hour,
                        endTime!.minute,
                      );
                      ctrl.addSlot(start, end);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Simpan Slot',
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

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.body),
        ],
      ),
    ),
  );
}
