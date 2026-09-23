import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';
import '../app/routes.dart';

/// Controller autentikasi: login, register, logout, dan state user
class AuthController extends GetxController {
  final _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// True setelah email reset password berhasil dikirim (FR-AUTH-05).
  final RxBool resetEmailSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  /// Load user dari Supabase saat controller init
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      // Anggap belum login (mis. session kosong), tapi tetap catat jejak
      // supaya error jaringan/Supabase asli tidak tersamar diam-diam
      // sebagai "belum login" biasa.
      // ignore: avoid_print
      print('AuthController._loadCurrentUser gagal: $e');
      currentUser.value = null;
    }
  }

  /// Login dan redirect ke dashboard sesuai role
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authService.signIn(email: email, password: password);
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
      _redirectByRole(user?.role);
    } catch (e) {
      errorMessage.value = 'Email atau password salah';
    } finally {
      isLoading.value = false;
    }
  }

  /// Register dan redirect ke dashboard
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      currentUser.value = user;
      _redirectByRole(user.role);
    } catch (e) {
      errorMessage.value = 'Registrasi gagal. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Kirim email reset password dan tandai hasilnya.
  ///
  /// Mekanismenya memakai Supabase Auth (FR-AUTH-05, sama dengan FR-AUTH-03),
  /// jadi tidak ada alur autentikasi baru yang diperkenalkan.
  Future<bool> resetPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';
    resetEmailSent.value = false;
    try {
      await _authService.resetPassword(email: email);
      resetEmailSent.value = true;
      return true;
    } catch (e) {
      errorMessage.value = 'Gagal mengirim email reset password. Coba lagi.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout dan kembali ke login screen
  Future<void> logout() async {
    await _authService.signOut();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navigasi berdasarkan role user
  void _redirectByRole(String? role) {
    if (role == 'tutor') {
      Get.offAllNamed(AppRoutes.tutorDashboard);
    } else {
      Get.offAllNamed(AppRoutes.customerDashboard);
    }
  }
}
