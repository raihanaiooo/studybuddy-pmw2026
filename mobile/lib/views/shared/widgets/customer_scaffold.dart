import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes.dart';
import 'app_bottom_nav.dart';

/// Wrapper untuk screen customer yang butuh bottom nav.
///
/// Cara pakai:
/// ```dart
/// CustomerScaffold(
///   currentIndex: 1, // 0=Beranda, 1=Cari, 2=Jadwal, 3=Profil
///   appBar: AppBar(...),
///   body: ...,
/// )
/// ```
class CustomerScaffold extends StatelessWidget {
  final int currentIndex;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const CustomerScaffold({
    super.key,
    required this.currentIndex,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
  });

  static const _navItems = [
    BottomNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    BottomNavItem(icon: Icons.search_rounded, label: 'Cari'),
    BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Jadwal'),
    BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  void _onNavTap(int i) {
    if (i == currentIndex) return;

    switch (i) {
      case 0:
        Get.offAllNamed(AppRoutes.customerDashboard);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.tutorList);
        break;
      case 2:
        Get.offAllNamed(AppRoutes.customerSchedule);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.customerProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF0F4FF),
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }
}
