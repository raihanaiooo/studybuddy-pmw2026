import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';

import '../../controllers/tutor/tutor_dashboard_controller.dart';
import '../../models/booking_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/status_badge.dart';

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TutorDashboardController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: c.isLoading.value,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryBlue,
                    onRefresh: c.loadDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DashHeader(c: c),
                          _EarningsCard(c: c),
                          _BookingTabs(c: c),
                          _SectionRow(),
                          _BookingList(c: c),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                AppBottomNav(
                  currentIndex: 0,
                  onTap: (i) {
                    if (i == 1) Get.toNamed('/tutor/schedule');
                    if (i == 3) Get.toNamed('/tutor/profile');
                  },
                  items: const [
                    BottomNavItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Dashboard',
                    ),
                    BottomNavItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Jadwal',
                    ),
                    BottomNavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                    ),
                    BottomNavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profil',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── HEADER ───────────────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  final TutorDashboardController c;
  const _DashHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
              // Top row: greeting + avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat pagi, Tutor 👋',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kak ${c.tutorProfile.value?.fullName ?? 'Tutor'}',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.blueLight, Color(0xFFA78BFA)],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (c.tutorProfile.value?.fullName ?? 'Tutor')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: AppTextStyles.heading3.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (c.isOnline.value)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.onlineGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.blueDark,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Online toggle bar
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onlineGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onlineGreen.withOpacity(0.25),
                              blurRadius: 0,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Online',
                            style: AppTextStyles.bodySemiBold.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Kamu bisa ditemukan customer',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Switch(
                        value: c.isOnline.value,
                        onChanged: c.toggleOnlineStatus,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.onlineGreen,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Stats row
              Obx(
                () => Row(
                  children: [
                    _StatChip(
                      value: '${c.bookingMasuk.value}',
                      label: 'Booking Masuk',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: '${c.sesiHariIni.value}',
                      label: 'Sesi Hari Ini',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: c.ratingRataRata.value.toStringAsFixed(1),
                      label: 'Rating Rata-rata',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EARNINGS CARD ────────────────────────────────────────────────────────────

class _EarningsCard extends StatelessWidget {
  final TutorDashboardController c;
  const _EarningsCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 Pendapatan Bulan Ini',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${_formatRupiah(c.pendapatanBulanIni.value)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+${c.pendapatanGrowth.value.toStringAsFixed(0)}% dari bulan lalu',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('📈', style: TextStyle(fontSize: 36)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}

// ─── BOOKING TABS ─────────────────────────────────────────────────────────────

class _BookingTabs extends StatelessWidget {
  final TutorDashboardController c;
  const _BookingTabs({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            _TabChip(
              label: 'Semua',
              count: c.bookings.length,
              isActive: c.activeFilter.value == 'all',
              onTap: () => c.setFilter('all'),
            ),
            const SizedBox(width: 8),
            _TabChip(
              label: 'Menunggu',
              count: c.pendingCount,
              isActive: c.activeFilter.value == 'pending',
              onTap: () => c.setFilter('pending'),
              countColor: AppColors.primaryYellow,
              countBg: const Color(0xFFFFF9EC),
            ),
            const SizedBox(width: 8),
            _TabChip(
              label: 'Dikonfirmasi',
              count: c.confirmedCount,
              isActive: c.activeFilter.value == 'confirmed',
              onTap: () => c.setFilter('confirmed'),
              countColor: const Color(0xFF16A34A),
              countBg: const Color(0xFFDCFCE7),
            ),
            const SizedBox(width: 8),
            _TabChip(label: 'Selesai', isActive: false, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isActive;
  final VoidCallback onTap;
  final Color? countColor;
  final Color? countBg;

  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.count,
    this.countColor,
    this.countBg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.25)
                      : (countBg ?? AppColors.background),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: isActive
                        ? Colors.white
                        : (countColor ?? AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── SECTION ROW ─────────────────────────────────────────────────────────────

class _SectionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('📋 Booking Masuk', style: AppTextStyles.heading3),
          Text(
            'Lihat Semua',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BOOKING LIST ─────────────────────────────────────────────────────────────

class _BookingList extends StatelessWidget {
  final TutorDashboardController c;
  const _BookingList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.filteredBookings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Tidak ada booking',
              style: AppTextStyles.body.copyWith(color: AppColors.textLight),
            ),
          ),
        );
      }
      return Column(
        children: c.filteredBookings
            .map((b) => _BookingCard(booking: b, c: c))
            .toList(),
      );
    });
  }
}

// ─── BOOKING CARD ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final TutorDashboardController c;
  const _BookingCard({required this.booking, required this.c});

  static const _avatarColors = [
    [Color(0xFFE63946), Color(0xFFFF6B74)],
    [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    [Color(0xFF0891B2), Color(0xFF22D3EE)],
    [Color(0xFF16A34A), Color(0xFF4ADE80)],
  ];

  Color _leftBorderColor() {
    switch (booking.status) {
      case 'pending':
        return AppColors.primaryYellow;
      case 'confirmed':
        return AppColors.onlineGreen;
      default:
        return AppColors.textLight;
    }
  }

  List<Color> _avatarGradient() {
    final idx = booking.customerName?.codeUnitAt(0) ?? 0;
    return _avatarColors[idx % _avatarColors.length];
  }

  String _formatDate(DateTime d) {
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
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime() {
    final start = booking.startTime.substring(0, 5).replaceAll(':', '.');
    final end = booking.endTime.substring(0, 5).replaceAll(':', '.');
    return '$start – $end (${booking.durationHours} jam)';
  }

  @override
  Widget build(BuildContext context) {
    final colors = _avatarGradient();
    final initial = (booking.customerName ?? '?').substring(0, 1).toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 4, color: _leftBorderColor()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.customerName ?? 'Pengguna',
                                  style: AppTextStyles.bodySemiBold.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📚 ${booking.subject}',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: booking.status),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Detail chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _DetailChip(
                            icon: Icons.calendar_today_rounded,
                            text: _formatDate(booking.sessionDate),
                          ),
                          _DetailChip(
                            icon: Icons.access_time_rounded,
                            text: _formatTime(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Action buttons
                      if (booking.status == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => c.rejectBooking(booking.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '✕ Tolak',
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => c.confirmBooking(booking.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '✓ Konfirmasi Booking',
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (booking.status == 'confirmed')
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Detail',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  // TODO: ganti dengan gmeet link dari tutor profile
                                  final uri = Uri.parse(
                                    'https://meet.google.com',
                                  );
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF22C55E),
                                        Color(0xFF16A34A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.videocam_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Buka GMeet',
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryBlue),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.label.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
