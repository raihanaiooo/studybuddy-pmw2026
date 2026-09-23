import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validator_utils.dart';
import '../../app/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  String _selectedRole = 'buddy';
  String? _selectedJenjang;
  bool _obscure = true;
  bool _parentConsentChecked = false;

  static const _jenjangOptions = ['SMP', 'SMA', 'Mahasiswa', 'Lulusan'];

  bool get _isMinor => _selectedRole == 'buddy' && _selectedJenjang == 'SMP';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.blueDark,
            size: 20,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Buat Akun Baru',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.blueDark,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar sebagai',
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _roleTab('buddy', '🎓 Buddy'),
                    _roleTab('tutor', '👨‍🏫 Tutor'),
                  ],
                ),
              ),
              if (_selectedRole == 'tutor')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryYellow.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '⚠️ Setelah mendaftar, kamu perlu mengunggah dokumen verifikasi sebelum bisa menerima booking.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              _label('Nama Lengkap'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => ValidatorUtils.required(v, 'Nama'),
                decoration: _inputDeco(
                  'Masukkan nama lengkap',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),

              _label('Email'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: ValidatorUtils.email,
                decoration: _inputDeco(
                  'contoh@email.com',
                  Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 16),

              _label('Nomor HP'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => ValidatorUtils.required(v, 'Nomor HP'),
                decoration: _inputDeco('08xxxxxxxxxx', Icons.phone_outlined),
              ),
              const SizedBox(height: 16),

              if (_selectedRole == 'buddy') ...[
                _label('Jenjang Pendidikan'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedJenjang,
                  decoration: _inputDeco(
                    'Pilih jenjang',
                    Icons.school_outlined,
                  ),
                  items: _jenjangOptions
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedJenjang = v;
                    if (v != 'SMP') _parentConsentChecked = false;
                  }),
                  validator: (v) => v == null ? 'Jenjang wajib dipilih' : null,
                ),
                const SizedBox(height: 16),
              ],

              if (_isMinor) ...[
                _buildParentConsentSection(),
                const SizedBox(height: 16),
              ],

              _label('Password'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                validator: ValidatorUtils.password,
                decoration: _inputDeco(
                  'Min. 8 karakter',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Obx(
                () => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          controller.errorMessage.value,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;
                            if (_isMinor && !_parentConsentChecked) {
                              Get.snackbar(
                                'Persetujuan Diperlukan',
                                'Orang tua/wali harus menyetujui pendaftaran untuk Buddy jenjang SMP.',
                              );
                              return;
                            }
                            controller.register(
                              email: _emailCtrl.text,
                              password: _passCtrl.text,
                              fullName: _nameCtrl.text,
                              role: _selectedRole,
                              phone: _phoneCtrl.text,
                              jenjang: _selectedRole == 'buddy'
                                  ? _selectedJenjang
                                  : null,
                              parentName: _isMinor
                                  ? _parentNameCtrl.text
                                  : null,
                              parentPhone: _isMinor
                                  ? _parentPhoneCtrl.text
                                  : null,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Daftar Sekarang',
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

  Widget _buildParentConsentSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryYellow.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.family_restroom,
              color: AppColors.primaryYellow,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Persetujuan Orang Tua/Wali',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Karena kamu masih SMP, pendaftaran ini perlu persetujuan orang tua/wali.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 12),
        _label('Nama Orang Tua/Wali'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _parentNameCtrl,
          validator: (v) => _isMinor && (v == null || v.trim().isEmpty)
              ? 'Nama orang tua wajib diisi'
              : null,
          decoration: _inputDeco(
            'Nama lengkap orang tua/wali',
            Icons.person_outline,
          ),
        ),
        const SizedBox(height: 12),
        _label('Nomor HP Orang Tua/Wali'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _parentPhoneCtrl,
          keyboardType: TextInputType.phone,
          validator: (v) => _isMinor && (v == null || v.trim().isEmpty)
              ? 'Nomor HP orang tua wajib diisi'
              : null,
          decoration: _inputDeco('08xxxxxxxxxx', Icons.phone_outlined),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _parentConsentChecked,
              onChanged: (v) =>
                  setState(() => _parentConsentChecked = v ?? false),
              activeColor: AppColors.primaryBlue,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(
                  () => _parentConsentChecked = !_parentConsentChecked,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Saya menyatakan bahwa orang tua/wali saya telah menyetujui pendaftaran dan penggunaan aplikasi Study Buddy.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _roleTab(String role, String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() {
        _selectedRole = role;
        if (role == 'tutor') {
          _selectedJenjang = null;
          _parentConsentChecked = false;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _selectedRole == role ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _selectedRole == role
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: _selectedRole == role
                  ? AppColors.primaryBlue
                  : AppColors.textLight,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _label(String text) => Text(
    text,
    style: AppTextStyles.bodySemiBold.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );

  InputDecoration _inputDeco(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.caption,
    prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
