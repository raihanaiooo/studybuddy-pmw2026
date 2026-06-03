import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../controllers/tutor/tutor_schedule_controller.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/status_badge.dart';
import '../../../app/routes.dart';

class TutorScheduleScreen extends StatelessWidget {
  const TutorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TutorScheduleController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => LoadingOverlay(
          isLoading: c.isLoading.value,
          child: RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: c.loadSchedule,
            child: CustomScrollView(
              slivers: [
                _buildHeader(c),
                _buildBookingRuleCard(),
                _buildDayPicker(c),
                _buildTimeSlots(c),
                _buildTodayBookings(c),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(TutorScheduleController c) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + Title + Refresh
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Kelola Jadwal Tutor',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: c.loadSchedule,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            'Status Ketersediaan: ${c.isOnline.value ? "Online" : "Offline"}',
                            style: AppTextStyles.bodySemiBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Customer bisa booking slot yang aktif sekarang',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: c.isOnline.value,
                      onChanged: c.toggleOnlineStatus,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.onlineGreen,
                      inactiveThumbColor: Colors.white54,
                      inactiveTrackColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Booking Rule Card ────────────────────────────────────────────────────────

  Widget _buildBookingRuleCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryYellow,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aturan Booking MVP',
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Slot hanya bisa dipesan minimal H-5 jam sebelum sesi dimulai. Slot yang terlalu dekat otomatis disembunyikan dari customer.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Day Picker ───────────────────────────────────────────────────────────────

  Widget _buildDayPicker(TutorScheduleController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pilih Hari Aktif Mingguan',
                  style: AppTextStyles.heading3,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(c.weekDays.length, (i) {
                  final day = c.weekDays[i];
                  final active = c.selectedDayIndex.value == i;
                  final isDisabled = day.label == 'Min';
                  return GestureDetector(
                    onTap: isDisabled ? null : () => c.selectDay(i),
                    child: Column(
                      children: [
                        Text(
                          day.label,
                          style: AppTextStyles.caption.copyWith(
                            color: active
                                ? AppColors.primaryBlue
                                : isDisabled
                                ? AppColors.textLight
                                : AppColors.textSecondary,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: !active && !isDisabled
                                ? Border.all(color: AppColors.border)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isDisabled ? '–' : day.date.toString(),
                            style: AppTextStyles.bodySemiBold.copyWith(
                              color: active
                                  ? Colors.white
                                  : isDisabled
                                  ? AppColors.textLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Time Slots ───────────────────────────────────────────────────────────────

  Widget _buildTimeSlots(TutorScheduleController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text('Slot Jam Mengajar', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.4,
                ),
                itemCount: c.timeSlots.length,
                itemBuilder: (_, i) {
                  final slot = c.timeSlots[i];
                  return _TimeSlotChip(
                    slot: slot,
                    onTap: () => c.toggleSlot(slot.time),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            // Legend
            Row(
              children: [
                _legend(AppColors.onlineGreen, 'Slot tersedia'),
                const SizedBox(width: 16),
                _legend(AppColors.primaryBlue, 'Sudah dibooking'),
                const SizedBox(width: 16),
                _legend(AppColors.border, 'Nonaktif'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  // ── Today Bookings ───────────────────────────────────────────────────────────

  Widget _buildTodayBookings(TutorScheduleController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text('Booking Masuk Hari Ini', style: AppTextStyles.heading3),
                  const Spacer(),
                  if (c.pendingConfirmCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withAlpha(
                          (0.15 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${c.pendingConfirmCount} perlu konfirmasi',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (c.todayBookings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Tidak ada booking hari ini',
                      style: AppTextStyles.caption,
                    ),
                  ),
                )
              else
                ...c.todayBookings.map((b) => _TodayBookingItem(booking: b)),
            ],
          );
        }),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return AppBottomNav(
      currentIndex: 1,
      items: const [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Home'),
        BottomNavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
        BottomNavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
        BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
      ],
      onTap: (i) {
        switch (i) {
          case 0:
            Get.offNamed(AppRoutes.tutorDashboard);
            break;
          case 3:
            Get.toNamed(AppRoutes.tutorProfile);
            break;
        }
      },
    );
  }
}

// ── Time Slot Chip ────────────────────────────────────────────────────────────

class _TimeSlotChip extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onTap;

  const _TimeSlotChip({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (slot.status) {
      case SlotStatus.available:
        bg = AppColors.onlineGreen;
        text = Colors.white;
        break;
      case SlotStatus.booked:
        bg = AppColors.primaryBlue.withAlpha((0.15 * 255).round());
        text = AppColors.primaryBlue;
        break;
      case SlotStatus.inactive:
        bg = Colors.white;
        text = AppColors.textSecondary;
        break;
    }

    return GestureDetector(
      onTap: slot.status == SlotStatus.booked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: slot.status == SlotStatus.inactive
              ? Border.all(color: AppColors.border)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          slot.time,
          style: AppTextStyles.bodySemiBold.copyWith(color: text),
        ),
      ),
    );
  }
}

// ── Today Booking Item ────────────────────────────────────────────────────────

class _TodayBookingItem extends StatelessWidget {
  final dynamic booking;

  const _TodayBookingItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.customerName ?? "Customer"} – ${booking.subject}',
                  style: AppTextStyles.bodySemiBold,
                ),
                Text(
                  '${booking.startTime.substring(0, 5)} – ${booking.endTime.substring(0, 5)} · ${booking.sessionType == "chat" ? "sesi chat + timer" : "via Google Meet"}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          StatusBadge(status: booking.status),
        ],
      ),
    );
  }
}
