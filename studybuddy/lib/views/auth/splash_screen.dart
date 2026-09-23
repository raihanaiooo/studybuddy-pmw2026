import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/supabase_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final session = SupabaseService.auth.currentSession;
    if (session == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      final data = await SupabaseService.client
          .from('users')
          .select('role')
          .eq('id', session.user.id)
          .single();

      final role = data['role'] as String?;

      if (role == 'tutor') {
        Get.offAllNamed(AppRoutes.tutorDashboard);
      } else if (role == 'admin') {
        Get.offAllNamed(AppRoutes.customerDashboard);
      } else {
        Get.offAllNamed(AppRoutes.customerDashboard);
      }
    } catch (e) {
      print('SplashScreen._checkSession gagal: $e');
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📚', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Study Buddy',
                style: AppTextStyles.heading1.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Belajar lebih mudah, lebih seru',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
