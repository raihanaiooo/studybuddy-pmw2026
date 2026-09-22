import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/tutor_dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../app/routes.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/status_badge.dart';

/// Dashboard utama Tutor: status online, statistik ringkas, booking masuk,
/// & link Google Meet permanen (FR-SESI-02, FR-DISC-05)
class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  int _navIndex = 0;

  final _navItems = const [
    BottomNavItem(icon: Icons.home_rounded, label: 'Dashboard'),
    BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Jadwal'),
    BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  void _onNavTap(int i) {
    // Jadwal & Profil adalah screen terpisah (push), bukan tab di dalam
    // Dashboard — indeks nav lokal jangan ikut berubah, supaya begitu
    // pengguna kembali (pop), Dashboard tetap menampilkan "Dashboard"
    // sebagai tab aktif, bukan ikut-ikutan menyorot tab yang baru saja
    // dituju.
    if (i == 1) {
      Get.toNamed(AppRoutes.tutorSchedule);
      return;
    }
    if (i == 2) {
      Get.toNamed(AppRoutes.tutorProfile);
      return;
    }
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final dashboard = Get.find<TutorDashboardController>();
    final booking = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(auth, dashboard),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(dashboard),
                  const SizedBox(height: 24),
                  _sectionHeader('Booking Masuk'),
                  const SizedBox(height: 12),
                  _buildIncomingBookings(booking),
                  const SizedBox(height: 24),
                  _sectionHeader('Link Google Meet Kamu'),
                  const SizedBox(height: 12),
                  _buildGmeetCard(context, dashboard),
                ],
              ),
            ),
          ),
          AppBottomNav(
            currentIndex: _navIndex,
            onTap: _onNavTap,
            items: _navItems,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthController auth, TutorDashboardController dashboard) =>
      Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        padding: EdgeInsets.fromLTRB(
          22,
          MediaQuery.of(context).padding.top + 20,
          22,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                'Halo, Kak ${auth.currentUser.value?.fullName.split(' ').first ?? 'Tutor'} 👋',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
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
                        const SizedBox(height: 2),
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
                      value: dashboard.isOnline.value,
                      onChanged: dashboard.isUpdatingStatus.value
                          ? null
                          : (v) => dashboard.toggleOnline(v, auth),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.onlineGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildStatsRow(TutorDashboardController dashboard) => Obx(
    () => Row(
      children: [
        Expanded(
          child: _statCard(
            '⭐ ${dashboard.avgRating.value}',
            'Rating Rata-rata',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('${dashboard.sessionsToday.value}', 'Sesi Hari Ini'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Rp${(dashboard.monthlyEarnings.value / 1000).toStringAsFixed(0)}rb',
            'Pendapatan Bulan Ini',
          ),
        ),
      ],
    ),
  );

  Widget _statCard(String value, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.06), blurRadius: 6),
      ],
    ),
    child: Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _sectionHeader(String title) => Text(title, style: AppTextStyles.heading3);

  Widget _buildIncomingBookings(BookingController booking) => Obx(() {
    final pending = booking.tutorBookings
        .where((b) => b.status == 'pending')
        .toList();
    if (pending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          'Belum ada booking masuk yang perlu dikonfirmasi',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      children: pending
          .map(
            (b) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                        child: Text(b.subject, style: AppTextStyles.bodySemiBold),
                      ),
                      StatusBadge(status: b.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppDateUtils.formatDateTime(b.sessionTime),
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              booking.updateBookingStatus(b.id, 'cancelled'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryRed),
                          ),
                          child: const Text(
                            'Tolak',
                            style: TextStyle(color: AppColors.primaryRed),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              booking.updateBookingStatus(b.id, 'confirmed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Konfirmasi'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  });

  Widget _buildGmeetCard(BuildContext context, TutorDashboardController dashboard) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.primaryBlue.withOpacity(0.06), blurRadius: 6),
          ],
        ),
        child: Obx(
          () => Column(
            children: List.generate(dashboard.gmeetLinks.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == dashboard.gmeetLinks.length - 1 ? 0 : 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dashboard.gmeetLinks[i],
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showEditLinkDialog(context, dashboard, i),
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      );

  void _showEditLinkDialog(
    BuildContext context,
    TutorDashboardController dashboard,
    int index,
  ) {
    final ctrl = TextEditingController(text: dashboard.gmeetLinks[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Link GMeet #${index + 1}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'meet.google.com/xxx-xxxx-xxx'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              dashboard.updateGmeetLink(index, ctrl.text);
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
