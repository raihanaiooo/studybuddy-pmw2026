import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/customer/booking_controller.dart';
import '../controllers/customer/questionnaire_controller.dart';
import '../controllers/manajemen/dashboard_controller.dart';
import '../controllers/tutor/tutor_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);

    Get.put(DashboardController(), permanent: true);

    Get.put(TutorController(), permanent: true);

    Get.put(BookingController(), permanent: true);

    Get.put(QuestionnaireController(), permanent: true);
  }
}
