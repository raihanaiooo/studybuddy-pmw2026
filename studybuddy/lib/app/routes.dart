import 'package:get/get.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/onboarding/buddy_onboarding_screen.dart';
import '../views/onboarding/tutor_onboarding_screen.dart';
import '../views/customer/dashboard_screen.dart';
import '../views/customer/tutor_list_screen.dart';
import '../views/customer/tutor_detail_screen.dart';
import '../views/customer/booking_screen.dart';
import '../views/customer/schedule_screen.dart';
import '../views/customer/profile_screen.dart';
import '../views/customer/package_screen.dart';
import '../views/customer/my_tokens_screen.dart';
import '../views/customer/invoice_screen.dart';
import '../views/customer/transaction_history_screen.dart';
import '../views/customer/reschedule_screen.dart';
import '../views/tutor/tutor_dashboard_screen.dart';
import '../views/tutor/tutor_schedule_screen.dart';
import '../views/tutor/tutor_profile_screen.dart';
import '../views/tutor/payroll_screen.dart';
import '../views/tutor/slip_gaji_screen.dart';
import '../views/session/session_screen.dart';
import '../views/session/review_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/tutor_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/session_controller.dart';
import '../controllers/review_controller.dart';
import '../controllers/tutor_dashboard_controller.dart';
import '../controllers/tutor_schedule_controller.dart';
import '../controllers/package_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/payment_controller.dart';
import '../controllers/reschedule_controller.dart';
import '../controllers/payroll_controller.dart';
import '../controllers/meet_link_controller.dart';
import '../controllers/package_controller.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const buddyOnboarding = '/onboarding/buddy';
  static const tutorOnboarding = '/onboarding/tutor';
  static const customerDashboard = '/customer/dashboard';
  static const tutorList = '/customer/tutors';
  static const tutorDetail = '/customer/tutor-detail';
  static const booking = '/customer/booking';
  static const customerSchedule = '/customer/schedule';
  static const customerProfile = '/customer/profile';
  static const packageCatalog = '/customer/packages';
  static const myTokens = '/customer/my-tokens';
  static const invoice = '/customer/invoice';
  static const transactionHistory = '/customer/transactions';
  static const reschedule = '/customer/reschedule';
  static const tutorDashboard = '/tutor/dashboard';
  static const tutorSchedule = '/tutor/schedule';
  static const tutorProfile = '/tutor/profile';
  static const payroll = '/tutor/payroll';
  static const slipGaji = '/tutor/slip-gaji';
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
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(name: buddyOnboarding, page: () => const BuddyOnboardingScreen()),
    GetPage(name: tutorOnboarding, page: () => const TutorOnboardingScreen()),
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
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => BookingController());
      }),
    ),
    GetPage(
      name: customerSchedule,
      page: () => const CustomerScheduleScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BookingController())),
    ),
    GetPage(
      name: packageCatalog,
      page: () => const PackageScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => PackageController());
      }),
    ),
    GetPage(
      name: myTokens,
      page: () => const MyTokensScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PackageController())),
    ),
    GetPage(
      name: customerProfile,
      page: () => const CustomerProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: tutorDashboard,
      page: () => const TutorDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => TutorDashboardController());
        Get.lazyPut(() => BookingController());
      }),
    ),
    GetPage(
      name: tutorSchedule,
      page: () => const TutorScheduleScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BookingController());
        Get.lazyPut(() => TutorScheduleController());
      }),
    ),
    GetPage(
      name: tutorProfile,
      page: () => const TutorProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => ProfileController());
        Get.lazyPut(() => MeetLinkController());
      }),
    ),
    GetPage(
      name: invoice,
      page: () => const InvoiceScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PaymentController())),
    ),
    GetPage(
      name: transactionHistory,
      page: () => const TransactionHistoryScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PaymentController())),
    ),
    GetPage(
      name: reschedule,
      page: () => const RescheduleScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => RescheduleController())),
    ),
    GetPage(
      name: payroll,
      page: () => const PayrollScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PayrollController())),
    ),
    GetPage(
      name: slipGaji,
      page: () => const SlipGajiScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PayrollController())),
    ),
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
