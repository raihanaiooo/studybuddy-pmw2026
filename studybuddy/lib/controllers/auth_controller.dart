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

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  /// Load user dari Supabase saat controller init
  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    currentUser.value = user;
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
