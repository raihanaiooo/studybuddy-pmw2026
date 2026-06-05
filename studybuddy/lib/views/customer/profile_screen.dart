import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/manajemen/dashboard_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../app/routes.dart';
import '../../shared/widgets/app_bottom_nav.dart';

/// Profile screen untuk customer: menampilkan info, stats, dan preferensi belajar
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  int _navIndex = 3;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _universityCtrl;
  late TextEditingController _semesterCtrl;

  bool _isEditing = false;

  final _navItems = const [
    BottomNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    BottomNavItem(icon: Icons.search_rounded, label: 'Cari'),
    BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Jadwal'),
    BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  void _onNavTap(int i) {
    if (i == 0) Get.offNamed(AppRoutes.customerDashboard);
    if (i == 1) Get.toNamed(AppRoutes.tutorList);
    if (i == 2) Get.toNamed(AppRoutes.customerSchedule);
    setState(() => _navIndex = i);
  }

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    _nameCtrl = TextEditingController(
      text: auth.currentUser.value?.fullName ?? '',
    );
    _phoneCtrl = TextEditingController(text: '+62 812 9123 4567');
    _bioCtrl = TextEditingController(
      text: 'Fokus memperkuat konsep dan persiapan ujian',
    );
    _universityCtrl = TextEditingController(text: 'Polban');
    _semesterCtrl = TextEditingController(text: '4');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _universityCtrl.dispose();
    _semesterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final dashboard = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Header gradient
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'Profil Saya',
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = !_isEditing),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isEditing
                                ? Icons.check_rounded
                                : Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Body scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                  child: Column(
                    children: [
                      // Profile card
                      _buildProfileCard(auth),
                      const SizedBox(height: 24),

                      // Stats cards
                      _buildStatsRow(dashboard),
                      const SizedBox(height: 24),

                      // Info section
                      _buildInformationSection(),
                      const SizedBox(height: 24),

                      // Preferences section
                      _buildPreferencesSection(),
                      const SizedBox(height: 24),

                      // Menu section
                      _buildMenuSection(),
                      const SizedBox(height: 24),

                      // Save button
                      if (_isEditing) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _isEditing = false);
                              Get.snackbar(
                                'Berhasil',
                                'Profil berhasil diperbarui',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.onlineGreen,
                                colorText: Colors.white,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Simpan Perubahan Profil',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppBottomNav(
              currentIndex: _navIndex,
              onTap: _onNavTap,
              items: _navItems,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AuthController auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: auth.currentUser.value?.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: auth.currentUser.value!.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const CircularProgressIndicator(),
                        errorWidget: (_, __, ___) => Center(
                          child: Text(
                            (auth.currentUser.value?.fullName ?? 'U')
                                .characters
                                .first
                                .toUpperCase(),
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          (auth.currentUser.value?.fullName ?? 'U')
                              .characters
                              .first
                              .toUpperCase(),
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                          ),
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
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teknik Industri · Semester 4 · Polban',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildTrustChip(
                          icon: Icons.verified_rounded,
                          label: 'Verifikasi Email',
                        ),
                        _buildTrustChip(
                          icon: Icons.school_rounded,
                          label: '8 Sesi Selesai',
                        ),
                        _buildTrustChip(
                          icon: Icons.star_rounded,
                          label: 'Rating 4.9',
                        ),
                      ],
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

  Widget _buildStatsRow(DashboardController dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total Booking',
            value: '12',
            icon: '📚',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(label: 'Sesi Selesai', value: '8', icon: '✓'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Rata-rata Review',
            value: '4.9',
            icon: '⭐',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading1.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Informasi Dasar', style: AppTextStyles.heading2),
            if (!_isEditing)
              Text('Bisa diubah kapan saja', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 16),
        // Nama Lengkap
        _buildInfoField(
          label: 'NAMA LENGKAP',
          controller: _nameCtrl,
          isEditable: _isEditing,
        ),
        const SizedBox(height: 12),
        // No. WhatsApp
        _buildInfoField(
          label: 'NO. WHATSAPP',
          controller: _phoneCtrl,
          isEditable: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        // Bio Belajar
        _buildInfoField(
          label: 'BIO BELAJAR',
          controller: _bioCtrl,
          isEditable: _isEditing,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferensi Belajar', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        // Universitas
        _buildInfoField(
          label: 'UNIVERSITAS',
          controller: _universityCtrl,
          isEditable: _isEditing,
        ),
        const SizedBox(height: 12),
        // Semester
        _buildInfoField(
          label: 'SEMESTER',
          controller: _semesterCtrl,
          isEditable: _isEditing,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        // Mata Kuliah Utama
        _buildPreferenceTag(
          icon: '📖',
          label: 'Mata Kuliah Utama',
          value: 'Statistika Industri',
        ),
        const SizedBox(height: 12),
        // Tujuan Belajar
        _buildPreferenceTag(
          icon: '🎯',
          label: 'Tujuan Belajar',
          value: 'Persiapan UTS/UAS',
        ),
        const SizedBox(height: 16),
        _buildKuesionerCard(),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : AppColors.background,
            border: Border.all(
              color: isEditable ? AppColors.primaryBlue : AppColors.border,
              width: isEditable ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            enabled: isEditable,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: label,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textLight,
              ),
            ),
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceTag({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$icon $label',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.body),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildKuesionerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.accentPurple.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuesioner rekomendasi aktif',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update terakhir: 2 hari lalu \u2022 5 tutor cocok',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.questionnaire),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Isi Ulang',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menu Profil Lainnya', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.star_rounded,
          iconColor: AppColors.primaryYellow,
          title: 'Riwayat Rating & Review',
          subtitle: 'Lihat ulasan yang pernah diberikan',
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.primaryRed,
          title: 'Tutor Favorit',
          subtitle: 'Daftar tutor pilihan untuk booking cepat',
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.accentTeal,
          title: 'Metode Pembayaran',
          subtitle: 'Atur rekening dan e-wallet utama',
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }
}
