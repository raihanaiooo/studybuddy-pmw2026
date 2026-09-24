import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validator_utils.dart';
import '../../app/routes.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user_model.dart';
import '../shared/widgets/customer_scaffold.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final profile = Get.find<ProfileController>();

    return CustomerScaffold(
      currentIndex: 3,
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
              _buildHeader(context, auth, user),
              const SizedBox(height: 20),
              _buildStatsRow(profile),
              const SizedBox(height: 20),
              _sectionTitle('Data Diri'),
              _infoTile('Nomor HP', user.phone ?? '-'),
              _infoTile('Jenjang', user.jenjang ?? '-'),
              _infoTile(
                'Mata Pelajaran Diminati',
                user.interestedSubjects.isEmpty
                    ? '-'
                    : user.interestedSubjects.join(', '),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primaryBlue,
                ),
                title: Text(
                  'Riwayat Transaksi',
                  style: AppTextStyles.bodySemiBold,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                ),
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

  Widget _buildHeader(
    BuildContext context,
    AuthController auth,
    UserModel user,
  ) {
    return Container(
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
          GestureDetector(
            onTap: () => _showAvatarOptions(context, auth),
            child: Stack(
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
                  clipBehavior: Clip.antiAlias,
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? Image.network(
                          user.avatarUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                        )
                      : Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: AppTextStyles.heading3),
                const SizedBox(height: 2),
                Text(user.email, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarOptions(
    BuildContext context,
    AuthController auth,
  ) async {
    final hasAvatar =
        auth.currentUser.value?.avatarUrl != null &&
        auth.currentUser.value!.avatarUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Foto Profil', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Get.back();
                _pickAvatar(auth);
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primaryRed,
                ),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
                onTap: () {
                  Get.back();
                  Get.find<ProfileController>().deleteAvatar(auth: auth);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar(AuthController auth) async {
    final pickedFiles = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (pickedFiles.isEmpty) return;
    final picked = pickedFiles.single;
    final bytes = await picked.readAsBytes();

    if (bytes.isEmpty) {
      Get.snackbar('Gagal', 'Tidak bisa membaca file.');
      return;
    }

    await Get.find<ProfileController>().uploadAvatar(
      auth: auth,
      fileName: picked.name,
      fileBytes: bytes,
    );
  }

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
        Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption),
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
        Expanded(flex: 2, child: Text(label, style: AppTextStyles.caption)),
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
    final subjectsCtrl = TextEditingController(
      text: user.interestedSubjects.join(', '),
    );
    String? selectedJenjang = user.jenjang;
    final formKey = GlobalKey<FormState>();

    const jenjangOptions = ['SMP', 'SMA', 'Mahasiswa', 'Lulusan'];

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
                  _formField(
                    'Nomor HP',
                    phoneCtrl,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedJenjang,
                    decoration: _inputDeco('Jenjang'),
                    items: jenjangOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => selectedJenjang = v,
                  ),
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
                                  jenjang: selectedJenjang,
                                  interestedSubjects: subjectsCtrl.text
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
    validator: (v) =>
        label == 'Nama Lengkap' ? ValidatorUtils.required(v, label) : null,
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
