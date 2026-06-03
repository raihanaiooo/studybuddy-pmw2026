import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../controllers/tutor/tutor_profile_controller.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../../../app/routes.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TutorProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => LoadingOverlay(
          isLoading: c.isSaving.value,
          child: CustomScrollView(
            slivers: [
              _buildHeader(c),
              _buildGmeetSection(c),
              _buildBioSection(c),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(TutorProfileController c) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Back + Title + Simpan
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Edit Profil',
                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                ),
                const Spacer(),
                Obx(
                  () => GestureDetector(
                    onTap: c.isSaving.value ? null : c.saveProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Simpan',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Avatar
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    c.profile.value?.fullName[0].toUpperCase() ?? 'T',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.blueDark, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.profile.value?.fullName ?? 'Tutor',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            // Stats row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _profileBadge(
                  '⭐ ${c.profile.value?.rating.toStringAsFixed(1) ?? "0.0"}',
                ),
                const SizedBox(width: 8),
                _profileBadge('${c.profile.value?.totalSessions ?? 0} Sesi'),
                const SizedBox(width: 8),
                _profileBadge(
                  '🟢 ${(c.profile.value?.isOnline ?? true) ? "Online" : "Offline"}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }

  // ── Google Meet Section ──────────────────────────────────────────────────────

  Widget _buildGmeetSection(TutorProfileController c) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Row(
              children: [
                const Text('🎥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('Link Google Meet', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            // Current link
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: Color(0xFF2E7D32),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LINK SAAT INI',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Obx(
                          () => Text(
                            c.gmeetCurrentCtrl.text.isNotEmpty
                                ? c.gmeetCurrentCtrl.text
                                : 'Belum ada link',
                            style: AppTextStyles.bodySemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: c.gmeetCurrentCtrl.text),
                      );
                      Get.snackbar(
                        'Disalin',
                        'Link berhasil disalin',
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(
                          (0.08 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        color: AppColors.primaryBlue,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Update current link
            Text(
              'UPDATE LINK GMEET',
              style: AppTextStyles.label.copyWith(letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: c.gmeetCurrentCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'meet.google.com/...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: const Color(0xFFF0FDF4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.onlineGreen),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.onlineGreen,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: AppColors.onlineGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  'Link aktif · Dipakai untuk semua sesi',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onlineGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // New link (optional)
            Text(
              'LINK BARU (OPSIONAL)',
              style: AppTextStyles.label.copyWith(letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: c.gmeetNewCtrl,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Tempel link GMeet baru di sini...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.primaryYellow,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pastikan link sudah aktif sebelum disimpan',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bio Section ──────────────────────────────────────────────────────────────

  Widget _buildBioSection(TutorProfileController c) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Row(
              children: [
                const Text('📝', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('Bio / Deskripsi Diri', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'CERITAKAN TENTANG DIRIMU',
              style: AppTextStyles.label.copyWith(letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: c.bioCtrl,
              style: AppTextStyles.body,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Ceritakan latar belakang pendidikan, pengalaman mengajar, dan keahlian kamu...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            // Error message
            Obx(
              () => c.saveError.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            c.saveError.value,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return AppBottomNav(
      currentIndex: 3,
      items: const [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
        BottomNavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
        BottomNavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
        BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
      ],
      onTap: (i) {
        switch (i) {
          case 0:
            Get.offNamed(AppRoutes.tutorDashboard);
            break;
          case 1:
            Get.offNamed(AppRoutes.tutorSchedule);
            break;
        }
      },
    );
  }
}
