import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tutor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/tutor_card.dart';
import '../shared/widgets/customer_scaffold.dart';

/// Dashboard utama customer: greeting, online tutors, quick access
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _navIndex = 0;

  final _navItems = const [
    BottomNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    BottomNavItem(icon: Icons.search_rounded, label: 'Cari'),
    BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Jadwal'),
    BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  void _onNavTap(int i) {
    if (i == 1) Get.toNamed(AppRoutes.tutorList);
    if (i == 2) Get.toNamed(AppRoutes.customerSchedule);
    if (i == 3) Get.toNamed(AppRoutes.customerProfile);
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final auth = Get.find<AuthController>();
    final tutorCtrl = Get.find<TutorController>();

    return CustomerScaffold(
      backgroundColor: AppColors.background,
      currentIndex: 0,
      body: Column(
        children: [
          // Header gradient
          _buildHeader(auth),
          // Body scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Butuh tutor sekarang? (on-demand)
                  _buildOnDemandBanner(),
                  const SizedBox(height: 16),

                  // Paket & Token
                  _buildPackageBanner(),
                  const SizedBox(height: 24),

                  // Tutor online sekarang
                  _buildSectionHeader(
                    '🟢 Tutor Online Sekarang',
                    onSeeAll: () {
                      Get.toNamed(AppRoutes.tutorList);
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (dashboard.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      );
                    }
                    if (dashboard.onlineTutors.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada tutor online saat ini',
                          style: AppTextStyles.caption,
                        ),
                      );
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dashboard.onlineTutors.length,
                        itemBuilder: (_, i) => TutorCard(
                          tutor: dashboard.onlineTutors[i],
                          compact: true,
                          onTap: () {
                            tutorCtrl.selectTutor(dashboard.onlineTutors[i]);
                            Get.toNamed(AppRoutes.tutorDetail);
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Semua tutor
                  _buildSectionHeader(
                    '👨‍🏫 Tutor Tersedia',
                    onSeeAll: () {
                      Get.toNamed(AppRoutes.tutorList);
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final tutors = tutorCtrl.tutors.take(4).toList();
                    return Column(
                      children: tutors
                          .map(
                            (t) => TutorCard(
                              tutor: t,
                              onTap: () {
                                tutorCtrl.selectTutor(t);
                                Get.toNamed(AppRoutes.tutorDetail);
                              },
                            ),
                          )
                          .toList(),
                    );
                  }),
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

  Widget _buildHeader(AuthController auth) => Container(
    decoration: const BoxDecoration(gradient: AppColors.headerGradient),
    padding: EdgeInsets.fromLTRB(
      22,
      MediaQuery.of(context).padding.top + 20,
      22,
      28,
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                'Hai, ${auth.currentUser.value?.fullName.split(' ').first ?? 'Pelajar'} 👋',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mau belajar apa hari ini?',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ],
        ),
        const Spacer(),
        // Notif bell
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        // Banner consent orang tua
        Obx(() {
          final user = auth.currentUser.value;
          if (user != null && user.needsParentConsent) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Persetujuan Orang Tua Diperlukan',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kamu belum bisa booking sampai data orang tua/wali dilengkapi. Hubungi admin.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    ),
  );

  /// Banner on-demand "Butuh tutor sekarang?"
  Widget _buildOnDemandBanner() => GestureDetector(
    onTap: () =>
        Get.toNamed(AppRoutes.tutorList, arguments: {'onlineOnly': true}),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryRed, AppColors.redLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Butuh Tutor Sekarang?',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                'Lihat tutor yang sedang online',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    ),
  );

  /// Banner akses cepat ke katalog Paket & Token (FR-PKG-01)
  Widget _buildPackageBanner() => GestureDetector(
    onTap: () => Get.toNamed(AppRoutes.packageCatalog),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('🎟️', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paket & Token', style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 2),
              Text(
                'Lihat katalog bundling & token belajarmu',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textLight,
            size: 14,
          ),
        ],
      ),
    ),
  );

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) => Row(
    children: [
      Text(title, style: AppTextStyles.heading3),
      const Spacer(),
      if (onSeeAll != null)
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'Lihat Semua',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ],
  );
}
