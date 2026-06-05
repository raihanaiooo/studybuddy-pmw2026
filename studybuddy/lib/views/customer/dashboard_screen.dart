import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/manajemen/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tutor/tutor_controller.dart';
import '../../controllers/customer/booking_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/utils/responsive_helper.dart';
import '../../app/routes.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/tutor_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../core/utils/date_utils.dart';

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
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final auth = Get.find<AuthController>();
    final tutorCtrl = Get.find<TutorController>();
    final isWide =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (_navIndex == 0) _buildHeader(auth),
          Expanded(child: _buildContent(dashboard, tutorCtrl, auth, isWide)),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }

  Widget _buildContent(
    DashboardController dashboard,
    TutorController tutorCtrl,
    AuthController auth,
    bool isWide,
  ) {
    switch (_navIndex) {
      case 0:
        return _buildHomeContent(dashboard, tutorCtrl, isWide);
      case 1:
        return _buildSearchContent(tutorCtrl);
      case 2:
        return _buildScheduleContent();
      case 3:
        return _buildProfileContent(auth);
      default:
        return _buildHomeContent(dashboard, tutorCtrl, isWide);
    }
  }

  Widget _buildHomeContent(
    DashboardController dashboard,
    TutorController tutorCtrl,
    bool isWide,
  ) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.contentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildOnDemandBanner(),
          const SizedBox(height: 16),
          _buildRekomendasiBanner(),
          const SizedBox(height: 24),

          _buildSectionHeader(
            '🟢 Tutor Online Sekarang',
            onSeeAll: () => setState(() => _navIndex = 1),
          ),

          const SizedBox(height: 12),

          Obx(() {
            if (dashboard.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
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

            if (isWide) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.gridColumns(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: dashboard.onlineTutors.length,
                itemBuilder: (_, i) => TutorCard(
                  tutor: dashboard.onlineTutors[i],
                  compact: true,
                  onTap: () {
                    tutorCtrl.selectTutor(dashboard.onlineTutors[i]);

                    Get.toNamed(AppRoutes.tutorDetail);
                  },
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

          _buildSectionHeader(
            '⭐ Tutor Untukmu',
            onSeeAll: () => setState(() => _navIndex = 1),
          ),

          const SizedBox(height: 12),

          _buildSubjectFilter(tutorCtrl),

          const SizedBox(height: 16),

          _buildSectionHeader(
            '👨‍🏫 Tutor Tersedia',
            onSeeAll: () => setState(() => _navIndex = 1),
          ),

          const SizedBox(height: 12),

          Obx(() {
            final tutors = tutorCtrl.tutors.take(6).toList();

            if (isWide) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.gridColumns(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemCount: tutors.length,
                itemBuilder: (_, i) => TutorCard(
                  tutor: tutors[i],
                  onTap: () {
                    tutorCtrl.selectTutor(tutors[i]);

                    Get.toNamed(AppRoutes.tutorDetail);
                  },
                ),
              );
            }

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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickStats() => Row(
    children: [
      _quickStatCard('📚', '12', 'Sesi Selesai'),
      const SizedBox(width: 10),
      _quickStatCard('⏱️', '24', 'Jam Belajar'),
      const SizedBox(width: 10),
      _quickStatCard('🔥', '7', 'Hari Streak'),
    ],
  );

  Widget _quickStatCard(String emoji, String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontFamily: 'Poppins',
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildSubjectFilter(TutorController tutorCtrl) {
    final subjects = [
      'Semua',
      'Matematika',
      'Fisika',
      'Kimia',
      'Statistik',
      'Pemrograman',
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: subjects.length,
        itemBuilder: (_, i) {
          final s = subjects[i];

          return Obx(() {
            final selected = tutorCtrl.selectedSubject.value == s;

            return GestureDetector(
              onTap: () {
                tutorCtrl.selectedSubject.value = s;

                if (s == 'Semua') {
                  tutorCtrl.searchQuery.value = '';
                } else {
                  tutorCtrl.searchQuery.value = s;
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.border,
                  ),
                ),
                child: Text(
                  s,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    fontSize: 12,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

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
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh Tutor Sekarang?',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final count =
                      Get.find<DashboardController>().onlineTutors.length;

                  return Text(
                    '$count tutor online & siap membantu',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildRekomendasiBanner() => GestureDetector(
    onTap: () => Get.toNamed(AppRoutes.questionnaire),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentPurple, AppColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temukan Tutor Ideal',
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Isi kuesioner untuk rekomendasi tutor yang sesuai',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSearchContent(TutorController ctrl) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => ctrl.searchQuery.value = v,
            decoration: InputDecoration(
              hintText: 'Cari tutor atau mata kuliah...',
              hintStyle: AppTextStyles.caption,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textLight,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = ctrl.filtered;

            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (list.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada tutor ditemukan',
                  style: AppTextStyles.caption,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              itemBuilder: (_, i) => TutorCard(
                tutor: list[i],
                onTap: () {
                  ctrl.selectTutor(list[i]);

                  Get.toNamed(AppRoutes.tutorDetail);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildScheduleContent() {
    final ctrl = Get.find<BookingController>();

    return Obx(() {
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
              Text('Belum ada jadwal', style: AppTextStyles.heading3),
              const SizedBox(height: 6),
              Text(
                'Booking tutor untuk mulai belajar!',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _navIndex = 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cari Tutor'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.myBookings.length,
        itemBuilder: (_, i) {
          final b = ctrl.myBookings[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${b.durationMinutes} menit',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    if (b.status == 'confirmed')
                      TextButton(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.session, arguments: b),
                        child: const Text('Mulai Sesi'),
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

  Widget _buildProfileContent(AuthController auth) {
    return Center(child: Text('Profil', style: AppTextStyles.heading2));
  }

  Widget _buildHeader(AuthController auth) => Container(
    decoration: const BoxDecoration(gradient: AppColors.headerGradient),
    padding: EdgeInsets.fromLTRB(
      ResponsiveHelper.horizontalPadding(context),
      MediaQuery.of(context).padding.top + 16,
      ResponsiveHelper.horizontalPadding(context),
      24,
    ),
    child: Row(
      children: [
        Obx(
          () => Text(
            'Hai, ${auth.currentUser.value?.fullName.split(' ').first ?? 'Pelajar'} 👋',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
        ),
      ],
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
