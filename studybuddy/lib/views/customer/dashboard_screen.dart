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

    return Scaffold(
      backgroundColor: AppColors.background,
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
