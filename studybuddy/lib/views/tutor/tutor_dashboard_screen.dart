import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../../app/routes.dart';
import '../../controllers/tutor/tutor_dashboard_controller.dart';
import '../../../models/booking_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/status_badge.dart';

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TutorDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => LoadingOverlay(
          isLoading: c.isLoading.value,
          child: RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: c.loadDashboard,
            child: CustomScrollView(
              slivers: [
                _buildHeader(c),
                _buildStats(c),
                _buildEarningsCard(c),
                _buildFilterTabs(c),
                _buildBookingList(c),
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

  Widget _buildHeader(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting + avatar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Selamat pagi, Tutor ',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const Text('👋', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          c.tutorProfile.value?.fullName ?? 'Tutor',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAvatar(c),
              ],
            ),
            const SizedBox(height: 16),
            // Status Online toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.onlineGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Online',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Kamu bisa ditemukan customer',
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

  Widget _buildAvatar(TutorDashboardController c) {
    final name = c.tutorProfile.value?.fullName ?? 'T';
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.25 * 255).round()),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.onlineGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────────────

  Widget _buildStats(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Obx(
          () => Row(
            children: [
              _statCard(
                value: c.bookingMasuk.value.toString(),
                label: 'Booking Masuk',
              ),
              const SizedBox(width: 12),
              _statCard(
                value: c.sesiHariIni.value.toString(),
                label: 'Sesi Hari Ini',
              ),
              const SizedBox(width: 12),
              _statCard(
                value: c.ratingRataRata.value.toStringAsFixed(1),
                label: 'Rating Rata-rata',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.blueLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Earnings Card ────────────────────────────────────────────────────────────

  Widget _buildEarningsCard(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Obx(
          () => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFAB5CF7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Pendapatan Bulan Ini',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_formatCurrency(c.pendapatanBulanIni.value)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${c.pendapatanGrowth.value.toStringAsFixed(0)}% dari bulan lalu',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter Tabs ──────────────────────────────────────────────────────────────

  Widget _buildFilterTabs(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Obx(
          () => Row(
            children: [
              _filterChip(
                c: c,
                label: 'Semua',
                value: 'all',
                count: c.bookings.length,
              ),
              const SizedBox(width: 8),
              _filterChip(
                c: c,
                label: 'Menunggu',
                value: 'pending',
                count: c.pendingCount,
              ),
              const SizedBox(width: 8),
              _filterChip(
                c: c,
                label: 'Dikonfirmasi',
                value: 'confirmed',
                count: c.confirmedCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip({
    required TutorDashboardController c,
    required String label,
    required String value,
    required int count,
  }) {
    final active = c.activeFilter.value == value;
    return GestureDetector(
      onTap: () => c.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          '$label  $count',
          style: AppTextStyles.bodySemiBold.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── Booking List ─────────────────────────────────────────────────────────────

  Widget _buildBookingList(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('Booking Masuk', style: AppTextStyles.heading2),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => c.filteredBookings.isEmpty
                  ? _buildEmpty()
                  : Column(
                      children: c.filteredBookings
                          .map((b) => _BookingCard(booking: b, controller: c))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(
            'Belum ada booking',
            style: AppTextStyles.body.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return AppBottomNav(
      currentIndex: 0,
      items: const [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
        BottomNavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
        BottomNavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
        BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
      ],
      onTap: (i) {
        switch (i) {
          case 1:
            Get.toNamed(AppRoutes.tutorSchedule);
            break;
          case 3:
            Get.toNamed(AppRoutes.tutorProfile);
            break;
        }
      },
    );
  }

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final TutorDashboardController controller;

  const _BookingCard({required this.booking, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: isPending ? AppColors.primaryYellow : AppColors.primaryBlue,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name + badge
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName ?? 'Customer',
                      style: AppTextStyles.heading3,
                    ),
                    Row(
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(booking.subject, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          // Date + Time
          Row(
            children: [
              _infoChip(
                icon: Icons.calendar_today_rounded,
                text: _formatDate(booking.sessionDate),
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              _infoChip(
                icon: Icons.access_time_rounded,
                text:
                    '${_formatTime(booking.startTime)} – ${_formatTime(booking.endTime)} (${booking.durationHours} jam)',
                color: AppColors.accentTeal,
              ),
            ],
          ),
          // Action buttons (only for pending)
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.rejectBooking(booking.id),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.confirmBooking(booking.id),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Konfirmasi Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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

  Widget _buildAvatar() {
    final name = booking.customerName ?? 'C';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.redLight],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String time) => time.substring(0, 5);
}
