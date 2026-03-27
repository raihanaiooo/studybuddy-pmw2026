import 'dart:async';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/session_model.dart';
import '../app/routes.dart';

/// Controller untuk sesi belajar: timer chat & launch GMeet
class SessionController extends GetxController {
  final Rx<SessionModel?> currentSession = Rx<SessionModel?>(null);
  final RxInt timerSeconds = 0.obs;
  final RxBool isTimerRunning = false.obs;
  Timer? _timer;

  /// Mulai sesi dari data booking
  Future<void> startSession(String bookingId, String? gmeetLink) async {
    final sessionData = {
      'booking_id': bookingId,
      'start_time': DateTime.now().toIso8601String(),
      'status': 'active',
      'gmeet_link': gmeetLink,
    };

    final data = await SupabaseService.client
        .from(SupabaseConstants.tableSessions)
        .insert(sessionData)
        .select()
        .single();

    currentSession.value = SessionModel.fromMap(data);

    // Auto-launch GMeet jika sesi video
    if (gmeetLink != null) {
      await _launchGmeet(gmeetLink);
    } else {
      _startTimer();
    }
  }

  /// Buka Google Meet di browser/app
  Future<void> _launchGmeet(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Mulai timer untuk sesi chat
  void _startTimer() {
    isTimerRunning.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timerSeconds.value++;
    });
  }

  /// Akhiri sesi dan navigasi ke review
  Future<void> endSession() async {
    _timer?.cancel();
    isTimerRunning.value = false;

    if (currentSession.value != null) {
      await SupabaseService.client
          .from(SupabaseConstants.tableSessions)
          .update({
            'end_time': DateTime.now().toIso8601String(),
            'status': 'ended',
            'elapsed_seconds': timerSeconds.value,
          })
          .eq('id', currentSession.value!.id);

      // Update status booking jadi 'done'
      await SupabaseService.client
          .from(SupabaseConstants.tableBookings)
          .update({'status': 'done'})
          .eq('id', currentSession.value!.bookingId);
    }

    Get.offNamed(AppRoutes.review);
  }

  /// Format timer: "01:23:45"
  String get timerFormatted {
    final h = timerSeconds.value ~/ 3600;
    final m = (timerSeconds.value % 3600) ~/ 60;
    final s = timerSeconds.value % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
