import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/realtime_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/tutor_model.dart';

/// Controller untuk dashboard: tutor online & statistik
class DashboardController extends GetxController {
  final _realtime = RealtimeService();

  final RxList<TutorModel> onlineTutors = <TutorModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchOnlineTutors();
    _subscribeOnlineTutors();
  }

  /// Fetch tutor yang sedang online dari Supabase
  Future<void> _fetchOnlineTutors() async {
    isLoading.value = true;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableTutors)
          .select()
          .eq('is_online', true)
          .order('rating', ascending: false);

      onlineTutors.value = (data as List)
          .map((e) => TutorModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Tangani error tanpa crash
    } finally {
      isLoading.value = false;
    }
  }

  /// Subscribe realtime update tutor online
  void _subscribeOnlineTutors() {
    _realtime.subscribeOnlineTutors((data) {
      onlineTutors.value = (data)
          .map((e) => TutorModel.fromMap(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  void onClose() {
    _realtime.dispose();
    super.onClose();
  }
}
