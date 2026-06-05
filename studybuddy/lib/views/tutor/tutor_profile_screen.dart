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

    return Obx(
      () => LoadingOverlay(
        isLoading: c.isLoading.value,

        child: Scaffold(
          backgroundColor: AppColors.background,

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        _ProfileHeader(c: c),

                        _GmeetSection(c: c),

                        const _Divider(),

                        _BioSection(c: c),

                        const _Divider(),

                        _SubjectSection(c: c),

                        _SaveButton(c: c),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                AppBottomNav(
                  currentIndex: 3,

                  onTap: (i) {
                    if (i == 0) Get.offNamed(AppRoutes.tutorDashboard);

                    if (i == 1) Get.offNamed(AppRoutes.tutorSchedule);
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

// ─── PROFILE HEADER ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final TutorProfileController c;

  const _ProfileHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),

      decoration: const BoxDecoration(gradient: AppColors.headerGradient),

      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -50,

            top: -50,

            child: Container(
              width: 180,

              height: 180,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Column(
            children: [
              // Nav row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  GestureDetector(
                    onTap: () => Get.back(),

                    child: Container(
                      width: 36,

                      height: 36,

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),

                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: const Icon(
                        Icons.arrow_back_rounded,

                        color: Colors.white,

                        size: 18,
                      ),
                    ),
                  ),

                  Text(
                    'Edit Profil',

                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,

                      fontSize: 16,

                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  GestureDetector(
                    onTap: c.saveProfile,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,

                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,

                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Text(
                        'Simpan',

                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,

                          fontWeight: FontWeight.w800,

                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar section
              Obx(
                () => Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,

                      children: [
                        Container(
                          width: 80,

                          height: 80,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),

                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,

                              end: Alignment.bottomRight,

                              colors: [AppColors.blueLight, Color(0xFFA78BFA)],
                            ),

                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),

                              width: 3,
                            ),
                          ),

                          child: Center(
                            child: Text(
                              (c.profile.value?.fullName ?? 'T')
                                  .substring(0, 1)
                                  .toUpperCase(),

                              style: AppTextStyles.heading1.copyWith(
                                color: Colors.white,

                                fontSize: 32,

                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: -4,

                          right: -4,

                          child: Container(
                            width: 24,

                            height: 24,

                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,

                              borderRadius: BorderRadius.circular(8),

                              border: Border.all(color: Colors.white, width: 2),
                            ),

                            child: const Icon(
                              Icons.edit_rounded,

                              size: 12,

                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      c.profile.value?.fullName ?? 'Tutor',

                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,

                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        _HeaderBadge(
                          '⭐ ${(c.profile.value?.rating ?? 0).toStringAsFixed(1)}',
                        ),

                        const SizedBox(width: 6),

                        _HeaderBadge(
                          '${c.profile.value?.totalSessions ?? 0} Sesi',
                        ),

                        const SizedBox(width: 6),

                        _HeaderBadge(
                          (c.profile.value?.isOnline ?? false)
                              ? '🟢 Online'
                              : '🔴 Offline',
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
}

class _HeaderBadge extends StatelessWidget {
  final String text;

  const _HeaderBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),

        borderRadius: BorderRadius.circular(50),
      ),

      child: Text(
        text,

        style: AppTextStyles.label.copyWith(
          color: Colors.white.withOpacity(0.85),

          fontSize: 10,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── GMEET SECTION ───────────────────────────────────────────────────────────

class _GmeetSection extends StatelessWidget {
  final TutorProfileController c;

  const _GmeetSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _SectionTitle(title: '📹 Link Google Meet'),

          const SizedBox(height: 12),

          // GMeet current card
          Obx(
            () => Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),

              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),

                border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Row(
                children: [
                  Container(
                    width: 36,

                    height: 36,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(10),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.10),

                          blurRadius: 8,

                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: const Center(
                      child: Text('📹', style: TextStyle(fontSize: 18)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'LINK SAAT INI',

                          style: AppTextStyles.label.copyWith(
                            color: const Color(0xFF16A34A),

                            fontWeight: FontWeight.w800,

                            fontSize: 10,

                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          c.gmeetLink.value.isEmpty
                              ? 'Belum ada link'
                              : c.gmeetLink.value,

                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 12,

                            fontWeight: FontWeight.w700,

                            color: AppColors.textPrimary,
                          ),

                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: c.gmeetLink.value));

                      Get.snackbar(
                        'Disalin!',

                        'Link GMeet berhasil disalin',

                        snackPosition: SnackPosition.BOTTOM,

                        backgroundColor: AppColors.onlineGreen,

                        colorText: Colors.white,
                      );
                    },

                    child: Container(
                      width: 32,

                      height: 32,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(8),

                        border: Border.all(
                          color: const Color(0xFFBBF7D0),

                          width: 1.5,
                        ),
                      ),

                      child: const Icon(
                        Icons.copy_rounded,

                        size: 14,

                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Current link field (read-only, green)
          _FormField(
            label: 'Update Link GMeet',

            child: Obx(
              () => _StyledTextField(
                controller: TextEditingController(text: c.gmeetLink.value),

                isGmeet: true,

                readOnly: true,

                hint: '',
              ),
            ),

            hint: '✓ Link aktif · Dipakai untuk semua sesi',

            hintColor: const Color(0xFF16A34A),
          ),

          const SizedBox(height: 0),

          // New link field
          _FormField(
            label: 'Link Baru (opsional)',

            child: _StyledTextField(
              controller: c.newGmeetController,

              hint: 'Tempel link GMeet baru di sini...',

              isFocused: true,
            ),

            hint: '⚠️ Pastikan link sudah aktif sebelum disimpan',
          ),
        ],
      ),
    );
  }
}

// ─── BIO SECTION ─────────────────────────────────────────────────────────────

class _BioSection extends StatelessWidget {
  final TutorProfileController c;

  const _BioSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _SectionTitle(title: '📝 Bio / Deskripsi Diri'),

          const SizedBox(height: 12),

          _FormField(
            label: 'Ceritakan tentang dirimu',

            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: AppColors.border, width: 1.5),
              ),

              child: TextField(
                controller: c.bioController,

                maxLines: 4,

                maxLength: 200,

                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 13,

                  fontWeight: FontWeight.w600,
                ),

                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(14),

                  border: InputBorder.none,

                  counterText: '',

                  hintText: 'Tulis bio singkat...',

                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textLight,

                    fontSize: 13,
                  ),
                ),
              ),
            ),

            hint: 'Maks. 200 karakter',
          ),
        ],
      ),
    );
  }
}

// ─── SUBJECT SECTION ─────────────────────────────────────────────────────────

class _SubjectSection extends StatelessWidget {
  final TutorProfileController c;

  const _SubjectSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _SectionTitle(title: '📚 Mata Kuliah yang Diajarkan'),

          const SizedBox(height: 12),

          // Input row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),

                  child: TextField(
                    controller: c.newSubjectController,

                    style: AppTextStyles.bodySemiBold.copyWith(
                      fontSize: 13,

                      fontWeight: FontWeight.w600,
                    ),

                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,

                        vertical: 10,
                      ),

                      border: InputBorder.none,

                      hintText: 'Tambah mata kuliah...',

                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textLight,

                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: c.addSubject,

                child: Container(
                  width: 40,

                  height: 40,

                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.add_rounded,

                    color: Colors.white,

                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Subject tags
          Obx(
            () => Wrap(
              spacing: 8,

              runSpacing: 8,

              children: c.subjects
                  .map(
                    (s) => _SubjectTag(
                      label: s,

                      onRemove: () => c.removeSubject(s),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 14),

          Obx(
            () => Text(
              '${c.subjects.length} mata kuliah terdaftar · Maks. 8',

              style: AppTextStyles.label.copyWith(
                color: AppColors.textLight,

                fontWeight: FontWeight.w600,

                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectTag extends StatelessWidget {
  final String label;

  final VoidCallback onRemove;

  const _SubjectTag({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),

      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),

        borderRadius: BorderRadius.circular(50),

        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(
            label,

            style: AppTextStyles.caption.copyWith(
              fontSize: 12,

              fontWeight: FontWeight.w700,

              color: AppColors.blueDark,
            ),
          ),

          const SizedBox(width: 6),

          GestureDetector(
            onTap: onRemove,

            child: Container(
              width: 16,

              height: 16,

              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.close_rounded,

                size: 8,

                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SAVE BUTTON ─────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final TutorProfileController c;

  const _SaveButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: c.saveProfile,

      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),

        padding: const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

            colors: [AppColors.blueDark, AppColors.primaryBlue],
          ),

          borderRadius: BorderRadius.circular(14),

          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.15),

              blurRadius: 20,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Center(
          child: Text(
            '💾 Simpan Perubahan',

            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,

              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,

          style: AppTextStyles.heading3.copyWith(
            fontSize: 13,

            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(width: 6),

        Expanded(child: Container(height: 1.5, color: AppColors.border)),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;

  final Widget child;

  final String? hint;

  final Color? hintColor;

  const _FormField({
    required this.label,

    required this.child,

    this.hint,

    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label.toUpperCase(),

          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,

            fontWeight: FontWeight.w800,

            fontSize: 11,

            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 6),

        child,

        if (hint != null) ...[
          const SizedBox(height: 4),

          Text(
            hint!,

            style: AppTextStyles.label.copyWith(
              color: hintColor ?? AppColors.textLight,

              fontWeight: FontWeight.w600,

              fontSize: 10,
            ),
          ),
        ],

        const SizedBox(height: 14),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hint;

  final bool readOnly;

  final bool isFocused;

  final bool isGmeet;

  const _StyledTextField({
    required this.controller,

    required this.hint,

    this.readOnly = false,

    this.isFocused = false,

    this.isGmeet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isGmeet ? const Color(0xFFF0FDF4) : Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: isGmeet
              ? AppColors.onlineGreen
              : isFocused
              ? AppColors.primaryBlue
              : AppColors.border,

          width: 1.5,
        ),

        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.12),

                  blurRadius: 0,

                  spreadRadius: 3,
                ),
              ]
            : null,
      ),

      child: TextField(
        controller: controller,

        readOnly: readOnly,

        style: AppTextStyles.bodySemiBold.copyWith(
          fontSize: 13,

          fontWeight: FontWeight.w600,

          color: isGmeet ? const Color(0xFF16A34A) : AppColors.textPrimary,
        ),

        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,

            vertical: 11,
          ),

          border: InputBorder.none,

          hintText: hint,

          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textLight,

            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,

      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),

      color: AppColors.border,
    );
  }
}
