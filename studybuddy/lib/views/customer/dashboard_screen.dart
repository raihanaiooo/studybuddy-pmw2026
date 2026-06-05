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
    final isWide = ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (_navIndex == 0) _buildHeader(auth),
          Expanded(
            child: _buildContent(dashboard, tutorCtrl, auth, isWide),
          ),
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

  // ── Tab 0: Beranda ─────────────────────────────────────────────────────

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

          // Online Tutors
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
                child: Text('Belum ada tutor online saat ini',
                    style: AppTextStyles.caption),
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

          // Subject Filter + Rekomendasi
          _buildSectionHeader(
            '⭐ Tutor Untukmu',
            onSeeAll: () => setState(() => _navIndex = 1),
          ),
          const SizedBox(height: 12),
          _buildSubjectFilter(tutorCtrl),
          const SizedBox(height: 16),

          // Tutor Tersedia
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
                  .map((t) => TutorCard(
                        tutor: t,
                        onTap: () {
                          tutorCtrl.selectTutor(t);
                          Get.toNamed(AppRoutes.tutorDetail);
                        },
                      ))
                  .toList(),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Quick Stats ────────────────────────────────────────────────────────

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

  // ── Subject Filter ─────────────────────────────────────────────────────

  Widget _buildSubjectFilter(TutorController tutorCtrl) {
    final subjects = [
      'Semua',
      'Matematika',
      'Fisika',
      'Kimia',
      'Statistik',
      'Pemrograman'
    ];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: subjects.length,
        itemBuilder: (_, i) {
          final s = subjects[i];
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected ? AppColors.primaryBlue : AppColors.border,
                ),
              ),
              child: Text(
                s,
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 12,
                  color:
                      selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Banners ────────────────────────────────────────────────────────────

  Widget _buildOnDemandBanner() => GestureDetector(
        onTap: () =>
            Get.toNamed(AppRoutes.tutorList, arguments: {'onlineOnly': true}),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.primaryRed, AppColors.redLight]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.primaryRed.withAlpha((0.3 * 255).round()),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Butuh Tutor Sekarang?',
                        style: AppTextStyles.heading3
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Obx(() {
                      final count = Get.find<DashboardController>().onlineTutors.length;
                      return Text('$count tutor online & siap membantu',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70));
                    }),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Cari 🚀',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryRed)),
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
                colors: [AppColors.accentPurple, AppColors.primaryBlue]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.accentPurple.withAlpha((0.3 * 255).round()),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Temukan Tutor Ideal',
                        style: AppTextStyles.heading3
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                        'Isi kuesioner untuk rekomendasi tutor yang sesuai',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      );

  // ── Tab 1: Cari Tutor ──────────────────────────────────────────────────

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
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textLight, size: 20),
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
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue));
            }
            if (list.isEmpty) {
              return Center(
                  child: Text('Tidak ada tutor ditemukan',
                      style: AppTextStyles.caption));
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

  // ── Tab 2: Jadwal ──────────────────────────────────────────────────────

  Widget _buildScheduleContent() {
    final ctrl = Get.find<BookingController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue));
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
              Text('Booking tutor untuk mulai belajar!',
                  style: AppTextStyles.caption),
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
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.primaryBlue.withAlpha((0.08 * 255).round()),
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
                        child:
                            Text(b.subject, style: AppTextStyles.heading3)),
                    StatusBadge(status: b.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text(AppDateUtils.formatDateTime(b.sessionTime),
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text('${b.durationMinutes} menit',
                        style: AppTextStyles.caption),
                    const Spacer(),
                    if (b.status == 'confirmed')
                      TextButton(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.session, arguments: b),
                        child: const Text('Mulai Sesi',
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700)),
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

  // ── Tab 3: Profil ──────────────────────────────────────────────────────

  Widget _buildProfileContent(AuthController auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withAlpha((0.8 * 255).round())
              ]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (auth.currentUser.value?.fullName ?? 'U')[0]
                              .toUpperCase(),
                          style: AppTextStyles.heading1
                              .copyWith(color: Colors.white, fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser.value?.fullName ?? 'User',
                            style: AppTextStyles.heading3
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Teknik Industri · Semester 4 · Polban',
                            style: AppTextStyles.caption
                                .copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withAlpha((0.2 * 255).round()),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text('Email Terverifikasi',
                                    style: AppTextStyles.caption
                                        .copyWith(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text('4.9',
                        style: AppTextStyles.heading3
                            .copyWith(color: Colors.white)),
                    const SizedBox(width: 2),
                    Text('Rating dari 12 Ulasan',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _profileStat('12', 'Total Booking'),
              const SizedBox(width: 12),
              _profileStat('8', 'Sesi Selesai'),
              const SizedBox(width: 12),
              _profileStat('4.9', 'Rating'),
            ],
          ),
          const SizedBox(height: 24),

          // Info
          _profileInfoCard('Informasi Dasar', [
            _profileInfoRow(Icons.person_outline, 'Nama',
                auth.currentUser.value?.fullName ?? '-'),
            _profileInfoRow(
                Icons.phone_outlined, 'WhatsApp', '+62 812 9123 4567'),
            _profileInfoRow(Icons.school_outlined, 'Universitas', 'Polban'),
            _profileInfoRow(Icons.book_outlined, 'Semester', '4'),
          ]),
          const SizedBox(height: 16),

          // Preferensi
          _profileInfoCard('Preferensi Belajar', [
            _profileInfoRow(Icons.bookmark_outline, 'Mata Kuliah Utama',
                'Statistika Industri'),
            _profileInfoRow(Icons.flag_outlined, 'Tujuan Belajar',
                'Persiapan UTS/UAS'),
          ]),
          const SizedBox(height: 16),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.find<AuthController>().logout(),
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.primaryRed),
              label: const Text('Keluar',
                  style: TextStyle(color: AppColors.primaryRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.heading1.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(value, style: AppTextStyles.bodySemiBold),
        ],
      ),
    );
  }

  // ── Header & Section ───────────────────────────────────────────────────

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    'Hai, ${auth.currentUser.value?.fullName.split(' ').first ?? 'Pelajar'} 👋',
                    style: AppTextStyles.heading2.copyWith(
                        color: Colors.white, fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Mau belajar apa hari ini?',
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white70)),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 22),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('3',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryYellow, AppColors.primaryRed]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withAlpha((0.3 * 255).round())),
              ),
              child: const Center(
                child: Text('🎓', style: TextStyle(fontSize: 18)),
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
              child: Text('Lihat Semua',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      );
}
