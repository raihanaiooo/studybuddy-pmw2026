import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';
import '../app/routes.dart';

class AuthController extends GetxController {
  final _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool resetEmailSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      print('AuthController._loadCurrentUser gagal: $e');
      currentUser.value = null;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authService.signIn(email: email, password: password);
      final user = await _authService.getCurrentUser();
      currentUser.value = user;

      if (user == null) {
        errorMessage.value = 'Profil tidak ditemukan';
        return;
      }

      _redirectByRole(user.role);
    } on AuthException catch (e) {
      print('AUTH EXCEPTION: ${e.message}');
      errorMessage.value = 'Email atau password salah';
    } on PostgrestException catch (e) {
      print('POSTGREST EXCEPTION: ${e.message}');
      errorMessage.value = 'Gagal memuat profil: ${e.message}';
    } catch (e, st) {
      print('UNKNOWN ERROR: $e');
      print(st);
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String phone,
    String? jenjang,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        jenjang: jenjang,
      );
      currentUser.value = user;
      _redirectAfterRegister(user.role);
    } on AuthException catch (e) {
      print('AUTH EXCEPTION: ${e.message}');
      errorMessage.value = 'Registrasi gagal: ${e.message}';
    } on PostgrestException catch (e) {
      print('POSTGREST EXCEPTION: ${e.message}');
      errorMessage.value = 'Gagal menyimpan profil: ${e.message}';
    } catch (e, st) {
      print('UNKNOWN ERROR: $e');
      print(st);
      errorMessage.value = 'Registrasi gagal. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> logout() async {
    await _authService.signOut();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  void _redirectByRole(String? role) {
    if (role == 'tutor') {
      Get.offAllNamed(AppRoutes.tutorDashboard);
    } else if (role == 'admin') {
      Get.offAllNamed(AppRoutes.customerDashboard);
    } else {
      Get.offAllNamed(AppRoutes.customerDashboard);
    }
  }

  void _redirectAfterRegister(String? role) {
    if (role == 'tutor') {
      Get.offAllNamed(AppRoutes.tutorOnboarding);
    } else {
      Get.offAllNamed(AppRoutes.buddyOnboarding);
    }
  }
}
