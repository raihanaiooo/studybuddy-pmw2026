import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
// import '../../shared/utils/responsive_helper.dart';
// import '../../controllers/auth_controller.dart';
import '../../controllers/tutor/tutor_dashboard_controller.dart';
// import '../../controllers/tutor/tutor_schedule_controller.dart';
// import '../../controllers/tutor/tutor_profile_controller.dart';
// import '../../models/booking_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/loading_overlay.dart';
// import '../../shared/widgets/status_badge.dart';
import '../tutor/booking_tabs.dart';
import '../../app/routes.dart';

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TutorDashboardController c = Get.find();

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
                          BookingTabs(c: c),
                          const SectionRow(),
                          BookingList(c: c),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                AppBottomNav(
                  currentIndex: 0,
                  onTap: (i) {
                    switch (i) {
                      case 0:
                        break; // already here
                      case 1:
                        Get.toNamed(AppRoutes.tutorSchedule);
                        break;
                      case 2:
                        Get.snackbar('Info', 'Fitur chat untuk tutor segera hadir',
                            snackPosition: SnackPosition.BOTTOM);
                        break;
                      case 3:
                        Get.toNamed(AppRoutes.tutorProfile);
                        break;
                    }
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
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(str[i]);
      count++;
    }

    return buffer.toString().split('').reversed.join();
  }
}
