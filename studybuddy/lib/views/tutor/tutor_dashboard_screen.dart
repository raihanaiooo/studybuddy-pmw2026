import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/responsive_helper.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tutor/tutor_dashboard_controller.dart';
import '../../controllers/tutor/tutor_schedule_controller.dart';
import '../../controllers/tutor/tutor_profile_controller.dart';
import '../../models/booking_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/status_badge.dart';

/// Dashboard tutor dengan persistent bottom nav
class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  int _navIndex = 0;

  final _navItems = const [
    BottomNavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    BottomNavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
    BottomNavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TutorDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => LoadingOverlay(
          isLoading: c.isLoading.value,
          child: _buildContent(c),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }

  Widget _buildContent(TutorDashboardController c) {
    switch (_navIndex) {
      case 0:
        return _buildDashboardTab(c);
      case 1:
        return _buildScheduleTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildDashboardTab(c);
    }
  }

  // ── Tab 0: Dashboard ───────────────────────────────────────────────────

  Widget _buildDashboardTab(TutorDashboardController c) {
    return RefreshIndicator(
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
    );
  }

  Widget _buildHeader(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.horizontalPadding(context),
          MediaQuery.of(context).padding.top + 16,
          ResponsiveHelper.horizontalPadding(context),
          24,
        ),
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Selamat pagi, Tutor ', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                          const Text('👋', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                        c.tutorProfile.value?.fullName ?? 'Tutor',
                        style: AppTextStyles.heading1.copyWith(color: Colors.white),
                      )),
                    ],
                  ),
                ),
                _buildAvatar(c),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.onlineGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Online', style: AppTextStyles.bodySemiBold.copyWith(color: Colors.white)),
                        Text('Kamu bisa ditemukan customer', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Obx(() => Switch(
                    value: c.isOnline.value,
                    onChanged: c.toggleOnlineStatus,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.onlineGreen,
                    inactiveThumbColor: Colors.white54,
                    inactiveTrackColor: Colors.white24,
                  )),
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
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.25 * 255).round()),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Poppins')),
        ),
        Positioned(
          right: 0, bottom: 0,
          child: Container(width: 14, height: 14, decoration: BoxDecoration(color: AppColors.onlineGreen, shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue, width: 2))),
        ),
      ],
    );
  }

  Widget _buildStats(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Obx(() => Row(
          children: [
            _statCard(value: c.bookingMasuk.value.toString(), label: 'Booking Masuk'),
            const SizedBox(width: 12),
            _statCard(value: c.sesiHariIni.value.toString(), label: 'Sesi Hari Ini'),
            const SizedBox(width: 12),
            _statCard(value: c.ratingRataRata.value.toStringAsFixed(1), label: 'Rating Rata-rata'),
          ],
        )),
      ),
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.blueLight]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.label.copyWith(color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFAB5CF7)]),
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
                        Text('Pendapatan Bulan Ini', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Rp ${_formatCurrency(c.pendapatanBulanIni.value)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('+${c.pendapatanGrowth.value.toStringAsFixed(0)}% dari bulan lalu', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.white.withAlpha((0.15 * 255).round()), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildFilterTabs(TutorDashboardController c) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Obx(() => Row(
          children: [
            _filterChip(c: c, label: 'Semua', value: 'all', count: c.bookings.length),
            const SizedBox(width: 8),
            _filterChip(c: c, label: 'Menunggu', value: 'pending', count: c.pendingCount),
            const SizedBox(width: 8),
            _filterChip(c: c, label: 'Dikonfirmasi', value: 'confirmed', count: c.confirmedCount),
          ],
        )),
      ),
    );
  }

  Widget _filterChip({required TutorDashboardController c, required String label, required String value, required int count}) {
    final active = c.activeFilter.value == value;
    return GestureDetector(
      onTap: () => c.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? [BoxShadow(color: AppColors.primaryBlue.withAlpha((0.3 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Text('$label  $count', style: AppTextStyles.bodySemiBold.copyWith(color: active ? Colors.white : AppColors.textSecondary, fontSize: 12)),
      ),
    );
  }

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
                Row(children: [const Text('📋', style: TextStyle(fontSize: 16)), const SizedBox(width: 6), Text('Booking Masuk', style: AppTextStyles.heading2)]),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => c.filteredBookings.isEmpty
              ? Container(width: double.infinity, padding: const EdgeInsets.all(32), child: Column(children: [const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textLight), const SizedBox(height: 12), Text('Belum ada booking', style: AppTextStyles.body.copyWith(color: AppColors.textLight))]))
              : Column(children: c.filteredBookings.map((b) => _BookingCard(booking: b, controller: c)).toList()),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Jadwal ──────────────────────────────────────────────────────

  Widget _buildScheduleTab() {
    final c = Get.find<TutorScheduleController>();
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: c.loadSchedule,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(ResponsiveHelper.horizontalPadding(context), MediaQuery.of(context).padding.top + 16, ResponsiveHelper.horizontalPadding(context), 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelola Jadwal', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Atur slot jam mengajar kamu', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ),
          // Booking rule
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.primaryYellow, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aturan Booking', style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryYellow)),
                        const SizedBox(height: 2),
                        Text('Slot hanya bisa dipesan minimal H-5 jam sebelum sesi dimulai.', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Day picker
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 8), Text('Pilih Hari Aktif', style: AppTextStyles.heading3)]),
                  const SizedBox(height: 14),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(c.weekDays.length, (i) {
                      final day = c.weekDays[i];
                      final active = c.selectedDayIndex.value == i;
                      final isDisabled = day.label == 'Min';
                      return GestureDetector(
                        onTap: isDisabled ? null : () => c.selectDay(i),
                        child: Column(
                          children: [
                            Text(day.label, style: AppTextStyles.caption.copyWith(color: active ? AppColors.primaryBlue : isDisabled ? AppColors.textLight : AppColors.textSecondary, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                            const SizedBox(height: 6),
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: active ? AppColors.primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(10), border: !active && !isDisabled ? Border.all(color: AppColors.border) : null),
                              alignment: Alignment.center,
                              child: Text(isDisabled ? '–' : day.date.toString(), style: AppTextStyles.bodySemiBold.copyWith(color: active ? Colors.white : isDisabled ? AppColors.textLight : AppColors.textPrimary)),
                            ),
                          ],
                        ),
                      );
                    }),
                  )),
                ],
              ),
            ),
          ),
          // Time slots
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 8), Text('Slot Jam Mengajar', style: AppTextStyles.heading3)]),
                  const SizedBox(height: 14),
                  Obx(() => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4),
                    itemCount: c.timeSlots.length,
                    itemBuilder: (_, i) {
                      final slot = c.timeSlots[i];
                      Color bg;
                      Color text;
                      switch (slot.status) {
                        case SlotStatus.available:
                          bg = AppColors.onlineGreen; text = Colors.white;
                          break;
                        case SlotStatus.booked:
                          bg = AppColors.primaryBlue.withAlpha((0.15 * 255).round()); text = AppColors.primaryBlue;
                          break;
                        case SlotStatus.inactive:
                          bg = Colors.white; text = AppColors.textSecondary;
                          break;
                      }
                      return GestureDetector(
                        onTap: slot.status == SlotStatus.booked ? null : () => c.toggleSlot(slot.time),
                        child: Container(
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: slot.status == SlotStatus.inactive ? Border.all(color: AppColors.border) : null),
                          alignment: Alignment.center,
                          child: Text(slot.time, style: AppTextStyles.bodySemiBold.copyWith(color: text)),
                        ),
                      );
                    },
                  )),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── Tab 2: Chat (placeholder) ─────────────────────────────────────────

  Widget _buildChatTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Chat', style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text('Fitur chat akan segera hadir', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Tab 3: Profil ──────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    final c = Get.find<TutorProfileController>();
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(ResponsiveHelper.horizontalPadding(context), MediaQuery.of(context).padding.top + 16, ResponsiveHelper.horizontalPadding(context), 24),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white.withAlpha((0.2 * 255).round()), borderRadius: BorderRadius.circular(22)),
                  alignment: Alignment.center,
                  child: Obx(() => Text(c.profile.value?.fullName[0].toUpperCase() ?? 'T', style: const TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(c.profile.value?.fullName ?? 'Tutor', style: AppTextStyles.heading2.copyWith(color: Colors.white))),
                const SizedBox(height: 8),
                Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _profileBadge('⭐ ${c.profile.value?.rating.toStringAsFixed(1) ?? "0.0"}'),
                    const SizedBox(width: 8),
                    _profileBadge('${c.profile.value?.totalSessions ?? 0} Sesi'),
                    const SizedBox(width: 8),
                    _profileBadge('🟢 ${(c.profile.value?.isOnline ?? true) ? "Online" : "Offline"}'),
                  ],
                )),
              ],
            ),
          ),
          // GMeet section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Text('🎥', style: TextStyle(fontSize: 16)), const SizedBox(width: 8), Text('Link Google Meet', style: AppTextStyles.heading3)]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: c.gmeetCurrentCtrl,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'meet.google.com/...',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
                      filled: true,
                      fillColor: const Color(0xFFF0FDF4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.onlineGreen)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.onlineGreen, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.onlineGreen), const SizedBox(width: 4), Text('Link aktif', style: AppTextStyles.caption.copyWith(color: AppColors.onlineGreen))]),
                ],
              ),
            ),
          ),
          // Bio section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Text('📝', style: TextStyle(fontSize: 16)), const SizedBox(width: 8), Text('Bio / Deskripsi', style: AppTextStyles.heading3)]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: c.bioCtrl,
                    style: AppTextStyles.body,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Ceritakan tentang dirimu...',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.find<AuthController>().logout(),
                icon: const Icon(Icons.logout_rounded, color: AppColors.primaryRed),
                label: Text('Keluar', style: TextStyle(color: AppColors.primaryRed)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryRed), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _profileBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withAlpha((0.2 * 255).round()), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: Colors.white)),
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
        border: Border(left: BorderSide(color: isPending ? AppColors.primaryYellow : AppColors.primaryBlue, width: 4)),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryRed, AppColors.redLight]), borderRadius: BorderRadius.all(Radius.circular(12))),
                alignment: Alignment.center,
                child: Text((booking.customerName ?? 'C')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Poppins')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.customerName ?? 'Customer', style: AppTextStyles.heading3),
                    Row(children: [const Text('📚', style: TextStyle(fontSize: 11)), const SizedBox(width: 4), Text(booking.subject, style: AppTextStyles.caption)]),
                  ],
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
              Text(_formatDate(booking.sessionDate), style: AppTextStyles.caption),
              const SizedBox(width: 12),
              Icon(Icons.access_time_rounded, size: 13, color: AppColors.accentTeal),
              const SizedBox(width: 4),
              Text('${_formatTime(booking.startTime)} – ${_formatTime(booking.endTime)}', style: AppTextStyles.caption),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => controller.rejectBooking(booking.id), icon: const Icon(Icons.close_rounded, size: 16), label: const Text('Tolak'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryRed, side: const BorderSide(color: AppColors.primaryRed), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () => controller.confirmBooking(booking.id), icon: const Icon(Icons.check_rounded, size: 16), label: const Text('Konfirmasi'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(String time) => time.substring(0, 5);
}
