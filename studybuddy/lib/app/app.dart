import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/constants/app_colors.dart';
import '../shared/constants/prototype.dart';
import 'routes.dart';

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Study Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
      ),
      initialRoute: kUseMock ? AppRoutes.login : AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
