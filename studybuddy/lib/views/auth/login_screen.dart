import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/prototype.dart';
import '../../shared/utils/responsive_helper.dart';

/// Screen login dengan quick-login role selection (prototype) + form login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final isWide = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient background (top half)
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          // Blob decorations
          Positioned(
            top: -80,
            right: -80,
            child: _blob(280, Colors.white.withAlpha((0.06 * 255).round())),
          ),
          Positioned(
            bottom: 150,
            left: -60,
            child: _blob(
              180,
              AppColors.primaryYellow.withAlpha((0.12 * 255).round()),
            ),
          ),

          SafeArea(
            child: isWide
                ? _buildWideLayout(controller)
                : _buildMobileLayout(controller),
          ),
        ],
      ),
    );
  }

  // ── Mobile Layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout(AuthController controller) {
    return Column(
      children: [
        // Logo & title
        _buildHeader(),
        // Bottom sheet
        Expanded(child: _buildFormSheet(controller)),
      ],
    );
  }

  // ── Wide (Tablet/Desktop) Layout ─────────────────────────────────────────

  Widget _buildWideLayout(AuthController controller) {
    return Center(
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 600),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.15 * 255).round()),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: branding
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text('📚', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Study Buddy',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Platform belajar peer-to-peer\nyang terpercaya',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right: form
            Expanded(
              flex: 1,
              child: _buildFormContent(controller, compact: true),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header (mobile) ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        30,
        MediaQuery.of(context).padding.top + 20,
        30,
        30,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.18 * 255).round()),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Study Buddy',
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Platform belajar terpercaya',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Sheet (mobile) ──────────────────────────────────────────────────

  Widget _buildFormSheet(AuthController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A1A1E3C),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 28, 26, 36),
        child: _buildFormContent(controller),
      ),
    );
  }

  // ── Form Content (shared) ────────────────────────────────────────────────

  Widget _buildFormContent(AuthController controller, {bool compact = false}) {
    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (!compact) ...[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (compact) const SizedBox(height: 12),
        Text(
          'Masuk ke Akun',
          style: AppTextStyles.heading2.copyWith(fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 6),
        Text('Selamat datang kembali!', style: AppTextStyles.caption),
        const SizedBox(height: 20),

        // Quick login section (prototype)
        if (kUseMock) ...[
          Text(
            'Quick Login (Prototype)',
            style: AppTextStyles.bodySemiBold.copyWith(
              fontSize: 12,
              color: AppColors.accentPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickLoginButtons(controller),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau login manual',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Email field
        _buildLabel('Email'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            'contoh@email.com',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),

        // Password field
        _buildLabel('Password'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: _inputDecoration(
            '••••••••',
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
        const SizedBox(height: 24),

        // Error message
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

        // Login button
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        controller.login(_emailCtrl.text, _passCtrl.text);
                      }
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Masuk',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Hint text for prototype
        if (kUseMock)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '💡 Tips: Email mengandung "tutor" → dashboard tutor\nEmail mengandung "admin" → dashboard manajemen',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Belum punya akun? ', style: AppTextStyles.caption),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: Text(
                'Daftar sekarang',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (compact) {
      return Form(
        key: _formKey,
        child: SingleChildScrollView(child: formColumn),
      );
    } else {
      return Form(key: _formKey, child: formColumn);
    }
  }

  // ── Quick Login Buttons ──────────────────────────────────────────────────

  Widget _buildQuickLoginButtons(AuthController controller) {
    return Row(
      children: [
        Expanded(
          child: _quickLoginCard(
            icon: Icons.person_rounded,
            label: 'Customer',
            color: AppColors.primaryBlue,
            email: 'customer@demo.com',
            onTap: () => controller.quickLogin('customer'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickLoginCard(
            icon: Icons.school_rounded,
            label: 'Tutor',
            color: AppColors.onlineGreen,
            email: 'tutor@demo.com',
            onTap: () => controller.quickLogin('tutor'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickLoginCard(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Manajemen',
            color: AppColors.accentPurple,
            email: 'admin@demo.com',
            onTap: () => controller.quickLogin('management'),
          ),
        ),
      ],
    );
  }

  Widget _quickLoginCard({
    required IconData icon,
    required String label,
    required Color color,
    required String email,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.08 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha((0.2 * 255).round())),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: AppTextStyles.caption.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
    text,
    style: AppTextStyles.bodySemiBold.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.caption,
    prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
