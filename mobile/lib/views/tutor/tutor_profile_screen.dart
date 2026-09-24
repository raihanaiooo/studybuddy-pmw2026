import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/tutor_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../shared/widgets/document_tile.dart';
import '../shared/widgets/verification_badge.dart';
import '../../controllers/meet_link_controller.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final profile = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil Tutor',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Obx(() {
        final tutor = profile.tutorProfile.value;
        if (tutor == null) {
          final String msg;
          if (profile.profileContractMissing.value) {
            msg = profile.errorMessage.value.isNotEmpty
                ? profile.errorMessage.value
                : 'Kontrak profil Tutor belum tersedia.';
          } else if (profile.isLoading.value) {
            msg = 'Memuat profil...';
          } else {
            msg = 'Profil belum dimuat. Coba lagi.';
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(tutor.fullName, tutor.university),
              const SizedBox(height: 12),
              Row(
                children: [VerificationBadge(status: tutor.verificationStatus)],
              ),
              if (tutor.verificationStatus == 'pending' ||
                  tutor.verificationStatus == 'rejected') ...[
                const SizedBox(height: 12),
                _pendingBanner(tutor.verificationNote),
              ],
              const SizedBox(height: 20),
              _buildStatsRow(tutor),
              const SizedBox(height: 20),
              _sectionHeader(
                'Bio & Mata Pelajaran',
                onEdit: () => _openEditProfileSheet(context, profile, tutor),
              ),
              const SizedBox(height: 8),
              _cardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tutor.bio, style: AppTextStyles.body),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tutor.subjects
                          .map((s) => _tagChip(s, AppColors.primaryBlue))
                          .toList(),
                    ),
                    if (tutor.jenjangDiajar.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Jenjang Diajar', style: AppTextStyles.caption),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tutor.jenjangDiajar
                            .map((s) => _tagChip(s, AppColors.accentTeal))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionHeader('Dokumen Verifikasi'),
              const SizedBox(height: 8),
              if (profile.tutorDocuments.isEmpty)
                _cardBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Belum ada dokumen. Hubungi admin untuk setup dokumen.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...profile.tutorDocuments.map(
                  (doc) => DocumentTile(document: doc),
                ),
              const SizedBox(height: 20),
              _sectionHeader('Link Google Meet'),
              const SizedBox(height: 8),
              _cardBox(
                child: Obx(() {
                  final meetCtrl = Get.find<MeetLinkController>();
                  if (meetCtrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minimal 1 link diperlukan agar Buddy bisa memulai sesi video. '
                        'Disarankan isi 3 link sebagai cadangan.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      ...meetCtrl.links.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (link.label != null &&
                                        link.label!.isNotEmpty)
                                      Text(
                                        link.label!,
                                        style: AppTextStyles.bodySemiBold,
                                      ),
                                    Text(
                                      link.meetLink,
                                      style: AppTextStyles.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.primaryRed,
                                  size: 20,
                                ),
                                onPressed: () => meetCtrl.removeLink(link.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openAddMeetLinkSheet(context, meetCtrl),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah Link'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                            foregroundColor: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _pendingBanner(String? reason) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primaryYellow.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline,
          color: AppColors.primaryYellow,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            reason ??
                'Belum bisa menerima booking sampai dokumen terverifikasi Admin.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryYellow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildHeader(String name, String university) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.08),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.blueLight],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.heading3),
              const SizedBox(height: 2),
              Text(university, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsRow(TutorModel tutor) => Row(
    children: [
      Expanded(child: _statCard('${tutor.rating}', 'Rating')),
      const SizedBox(width: 12),
      Expanded(child: _statCard('${tutor.totalSessions}', 'Sesi Selesai')),
      const SizedBox(width: 12),
      Expanded(child: _statCard('${tutor.totalReviews}', 'Ulasan')),
    ],
  );

  Widget _statCard(String value, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.06),
          blurRadius: 6,
        ),
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

  Widget _sectionHeader(String title, {VoidCallback? onEdit}) => Row(
    children: [
      Text(title, style: AppTextStyles.heading3),
      const Spacer(),
      if (onEdit != null)
        GestureDetector(
          onTap: onEdit,
          child: Text(
            'Edit',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ],
  );

  Widget _cardBox({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.06),
          blurRadius: 6,
        ),
      ],
    ),
    child: child,
  );

  Widget _tagChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  void _openAddMeetLinkSheet(BuildContext context, MeetLinkController ctrl) {
    final urlCtrl = TextEditingController();
    final labelCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Link Meet', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              TextField(
                controller: urlCtrl,
                decoration: _inputDeco('https://meet.google.com/xxx-xxxx-xxx'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelCtrl,
                decoration: _inputDeco('Label (opsional, mis: Link Utama)'),
              ),
              const SizedBox(height: 20),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: ctrl.isLoading.value
                        ? null
                        : () async {
                            final ok = await ctrl.addLink(
                              meetLink: urlCtrl.text,
                              label: labelCtrl.text.isEmpty
                                  ? null
                                  : labelCtrl.text,
                            );
                            if (ok) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: ctrl.isLoading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditProfileSheet(
    BuildContext context,
    ProfileController profile,
    TutorModel tutor,
  ) {
    final bioCtrl = TextEditingController(text: tutor.bio);
    final subjectsCtrl = TextEditingController(text: tutor.subjects.join(', '));
    final jenjangCtrl = TextEditingController(
      text: tutor.jenjangDiajar.join(', '),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Bio & Mata Pelajaran',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bioCtrl,
                  maxLines: 3,
                  decoration: _inputDeco('Bio'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectsCtrl,
                  decoration: _inputDeco('Mata Pelajaran (pisahkan koma)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jenjangCtrl,
                  decoration: _inputDeco(
                    'Jenjang Diajar (pisahkan koma: SMP, SMA, Mahasiswa)',
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: profile.isLoading.value
                          ? null
                          : () async {
                              final ok = await profile.saveTutorProfile(
                                bio: bioCtrl.text,
                                subjects: subjectsCtrl.text
                                    .split(',')
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .toList(),
                                jenjangDiajar: jenjangCtrl.text
                                    .split(',')
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .toList(),
                              );
                              if (ok) Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: profile.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
