// ─────IMPORT FLUTTER PACKAGES/MODULES─────────────────────────────────────────────────────────────────────────
import 'package:get/get.dart';

// ─────IMPORT SCREENS ──────────────────────────────────────────────────────────────────────────────
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/customer/dashboard_screen.dart';
import '../views/customer/tutor_list_screen.dart';
import '../views/customer/tutor_detail_screen.dart';
import '../views/customer/booking_screen.dart';
import '../views/customer/schedule_screen.dart';
import '../views/customer/profile_screen.dart';
import '../views/session/session_screen.dart';
import '../views/session/review_screen.dart';
import '../views/management/operational_screen.dart';
import '../views/management/management_dashboard_screen.dart';
import '../views/management/tutor_approval_screen.dart';
import '../views/tutor/tutor_schedule_screen.dart';
import '../views/tutor/tutor_profile_screen.dart';
import '../views/tutor/tutor_dashboard_screen.dart';
import '../views/customer/questionnaire_screen.dart';

// ─────IMPORT CONTROLLERS──────────────────────────────────────────────────────────────────────────────
import '../controllers/auth_controller.dart';
import '../controllers/manajemen/dashboard_controller.dart';
import '../controllers/tutor/tutor_controller.dart';
import '../controllers/customer/booking_controller.dart';
import '../controllers/customer/session_controller.dart';
import '../controllers/customer/review_controller.dart';
import '../controllers/manajemen/operational_controller.dart';
import '../controllers/manajemen/tutor_approval_controller.dart';
import '../controllers/tutor/tutor_dashboard_controller.dart';
import '../controllers/tutor/tutor_schedule_controller.dart';
import '../controllers/tutor/tutor_profile_controller.dart';
import '../controllers/customer/questionnaire_controller.dart';

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
  static const questionnaire = '/customer/questionnaire';
  static const tutorDashboard = '/tutor/dashboard';
  static const tutorSchedule = '/tutor/schedule';
  static const tutorProfile = '/tutor/profile';
  static const session = '/session';
  static const review = '/review';
  static const operational = '/operational';
  static const managementDashboard = '/management/dashboard';
  static const tutorApproval = '/management/tutor-approval';

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
        Get.lazyPut(() => BookingController());
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
    GetPage(
      name: customerProfile,
      page: () => const CustomerProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: questionnaire,
      page: () => const QuestionnaireScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => QuestionnaireController());
      }),
    ),
    // ── Tutor routes ──────────────────────────────────────────────────────────
    GetPage(
      name: tutorDashboard,
      page: () => const TutorDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => TutorDashboardController());
        Get.lazyPut(() => TutorScheduleController());
        Get.lazyPut(() => TutorProfileController());
      }),
    ),
    GetPage(
      name: tutorSchedule,
      page: () => const TutorScheduleScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => TutorDashboardController());
        Get.lazyPut(() => TutorScheduleController());
        Get.lazyPut(() => TutorProfileController());
      }),
    ),
    GetPage(
      name: tutorProfile,
      page: () => const TutorProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TutorProfileController());
      }),
    ),
    // ── Shared routes ─────────────────────────────────────────────────────────
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
    // ── Management routes ─────────────────────────────────────────────────────
    GetPage(
      name: managementDashboard,
      page: () => const ManagementDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => OperationalController());
      }),
    ),
    GetPage(
      name: tutorApproval,
      page: () => const TutorApprovalScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TutorApprovalController());
      }),
    ),
    GetPage(
      name: operational,
      page: () => const OperationalScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => OperationalController()),
      ),
    ),
  ];
}
