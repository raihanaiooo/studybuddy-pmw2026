import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validator_utils.dart';
import '../../app/routes.dart';

/// Profil Buddy: data diri, mata pelajaran diminati, riwayat & aktivitas
/// (FR-PROF-01, FR-PROF-03, FR-PROF-04)
class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

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
          'Profil Saya',
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
        final user = auth.currentUser.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user.fullName, user.email),
              const SizedBox(height: 20),
              _buildStatsRow(profile),
              const SizedBox(height: 20),
              _sectionTitle('Data Diri'),
              _infoTile('Nomor HP', user.phone ?? '-'),
              _infoTile('Usia', user.age?.toString() ?? '-'),
              _infoTile('Jenjang', user.gradeLevel ?? '-'),
              _infoTile('Asal Sekolah/Kampus', user.school ?? '-'),
              _infoTile(
                'Mata Pelajaran Diminati',
                user.interestedSubjects.isEmpty
                    ? '-'
                    : user.interestedSubjects.join(', '),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryBlue),
                title: Text('Riwayat Transaksi', style: AppTextStyles.bodySemiBold),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
                onTap: () => Get.toNamed(AppRoutes.transactionHistory),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _openEditSheet(context, auth, profile),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(String name, String email) => Container(
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
              Text(email, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsRow(ProfileController profile) => Obx(
    () => Row(
      children: [
        Expanded(
          child: _statCard(
            '${profile.completedSessions.value}',
            'Sesi Selesai',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            profile.avgRatingGiven.value.toStringAsFixed(1),
            'Rata-rata Rating Diberikan',
          ),
        ),
      ],
    ),
  );

  Widget _statCard(String value, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          style: AppTextStyles.heading2.copyWith(color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      ],
    ),
  );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: AppTextStyles.heading3),
  );

  Widget _infoTile(String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySemiBold,
          ),
        ),
      ],
    ),
  );

  void _openEditSheet(
    BuildContext context,
    AuthController auth,
    ProfileController profile,
  ) {
    final user = auth.currentUser.value!;
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final ageCtrl = TextEditingController(text: user.age?.toString() ?? '');
    final schoolCtrl = TextEditingController(text: user.school ?? '');
    final subjectsCtrl = TextEditingController(
      text: user.interestedSubjects.join(', '),
    );
    String gradeLevel = user.gradeLevel ?? 'Mahasiswa (S1)';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit Profil', style: AppTextStyles.heading2),
                  const SizedBox(height: 16),
                  _formField('Nama Lengkap', nameCtrl),
                  const SizedBox(height: 12),
                  _formField('Nomor HP', phoneCtrl, keyboard: TextInputType.phone),
                  const SizedBox(height: 12),
                  _formField('Usia', ageCtrl, keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: gradeLevel,
                    decoration: _inputDeco('Jenjang'),
                    items: const [
                      'SMP',
                      'SMA/sederajat',
                      'Mahasiswa (S1)',
                      'Lulusan',
                      'Umum',
                    ]
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => gradeLevel = v ?? gradeLevel,
                  ),
                  const SizedBox(height: 12),
                  _formField('Asal Sekolah/Kampus', schoolCtrl),
                  const SizedBox(height: 12),
                  _formField(
                    'Mata Pelajaran Diminati (pisahkan koma)',
                    subjectsCtrl,
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
                                if (!formKey.currentState!.validate()) return;
                                final ok = await profile.saveBuddyProfile(
                                  auth: auth,
                                  fullName: nameCtrl.text,
                                  phone: phoneCtrl.text.isEmpty
                                      ? null
                                      : phoneCtrl.text,
                                  age: int.tryParse(ageCtrl.text),
                                  gradeLevel: gradeLevel,
                                  school: schoolCtrl.text.isEmpty
                                      ? null
                                      : schoolCtrl.text,
                                  interestedSubjects: subjectsCtrl.text
                                      .split(',')
                                      .map((s) => s.trim())
                                      .where((s) => s.isNotEmpty)
                                      .toList(),
                                );
                                // Tutup sheet HANYA saat backend
                                // mengonfirmasi — saat gagal biarkan
                                // pengguna mencoba ulang.
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
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboard,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: keyboard,
    validator: (v) => label == 'Nama Lengkap'
        ? ValidatorUtils.required(v, label)
        : null,
    decoration: _inputDeco(label),
  );

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
