import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';
import '../mock/mock_data.dart';
import '../shared/constants/prototype.dart';
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

  /// Login statis untuk prototype — pilih role, langsung masuk
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kUseMock) {
        // Simulasi delay
        await Future.delayed(const Duration(milliseconds: 600));

        // Tentukan role berdasarkan email prefix
        UserModel user;
        if (email.toLowerCase().contains('tutor')) {
          user = mockTutorUser;
        } else if (email.toLowerCase().contains('admin') ||
            email.toLowerCase().contains('manajemen') ||
            email.toLowerCase().contains('management')) {
          user = mockManagementUser;
        } else {
          user = mockCustomer;
        }

        currentUser.value = user;
        _redirectByRole(user.role);
        return;
      }

      // Real mode: gunakan Supabase
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

  /// Quick login: langsung masuk berdasarkan role tanpa validasi
  Future<void> quickLogin(String role) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      switch (role) {
        case 'customer':
          currentUser.value = mockCustomer;
          Get.offAllNamed(AppRoutes.customerDashboard);
          break;
        case 'tutor':
          currentUser.value = mockTutorUser;
          Get.offAllNamed(AppRoutes.tutorDashboard);
          break;
        case 'management':
          currentUser.value = mockManagementUser;
          Get.offAllNamed(AppRoutes.managementDashboard);
          break;
        default:
          currentUser.value = mockCustomer;
          Get.offAllNamed(AppRoutes.customerDashboard);
      }
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
      if (kUseMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        final user = UserModel(
          id: 'new_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          fullName: fullName,
          role: role,
          createdAt: DateTime.now(),
        );
        currentUser.value = user;
        _redirectByRole(user.role);
        return;
      }

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
    if (!kUseMock) {
      await _authService.signOut();
    }
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navigasi berdasarkan role user
  void _redirectByRole(String? role) {
    switch (role) {
      case 'tutor':
        Get.offAllNamed(AppRoutes.tutorDashboard);
        break;
      case 'management':
        Get.offAllNamed(AppRoutes.managementDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.customerDashboard);
    }
  }
}
