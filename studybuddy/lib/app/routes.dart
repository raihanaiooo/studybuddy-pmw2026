import 'package:get/get.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/customer/dashboard_screen.dart';
import '../views/customer/tutor_list_screen.dart';
import '../views/customer/tutor_detail_screen.dart';
import '../views/customer/booking_screen.dart';
import '../views/customer/schedule_screen.dart';
import '../views/customer/profile_screen.dart';
import '../views/tutor/tutor_dashboard_screen.dart';
import '../views/tutor/tutor_schedule_screen.dart';
import '../views/tutor/tutor_profile_screen.dart';
import '../views/session/session_screen.dart';
import '../views/session/review_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/tutor_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/session_controller.dart';
import '../controllers/review_controller.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const customerDashboard = '/customer/dashboard';
  static const tutorList = '/customer/tutors';
  static const tutorDetail = '/customer/tutor-detail';
  static const booking = '/customer/booking';
  static const customerSchedule = '/customer/schedule';
  static const customerProfile = '/customer/profile';
  static const tutorDashboard = '/tutor/dashboard';
  static const tutorSchedule = '/tutor/schedule';
  static const tutorProfile = '/tutor/profile';
  static const session = '/session';
  static const review = '/review';

  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: customerDashboard,
      page: () => const CustomerDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => DashboardController());
        Get.lazyPut(() => TutorController());
      }),
    ),
    GetPage(
      name: tutorList,
      page: () => const TutorListScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TutorController())),
    ),
    GetPage(
      name: tutorDetail,
      page: () => const TutorDetailScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TutorController())),
    ),
    GetPage(
      name: booking,
      page: () => const BookingScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BookingController())),
    ),
    GetPage(
      name: customerSchedule,
      page: () => const CustomerScheduleScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BookingController())),
    ),
    // GetPage(
    //   name: customerProfile,
    //   page: () => const CustomerProfileScreen(),
    //   binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    // ),
    // GetPage(
    //   name: tutorDashboard,
    //   page: () => const TutorDashboardScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => DashboardController());
    //     Get.lazyPut(() => BookingController());
    //   }),
    // ),
    // GetPage(
    //   name: tutorSchedule,
    //   page: () => const TutorScheduleScreen(),
    //   binding: BindingsBuilder(() => Get.lazyPut(() => BookingController())),
    // ),
    // GetPage(
    //   name: tutorProfile,
    //   page: () => const TutorProfileScreen(),
    //   binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    // ),
    GetPage(
      name: session,
      page: () => const SessionScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SessionController())),
    ),
    GetPage(
      name: review,
      page: () => const ReviewScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ReviewController())),
    ),
  ];
}
