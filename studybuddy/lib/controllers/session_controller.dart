import 'dart:async';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/supabase_constants.dart';
import '../models/session_model.dart';
import '../models/booking_model.dart';
import '../app/routes.dart';

class SessionController extends GetxController {
  final Rx<SessionModel?> currentSession = Rx<SessionModel?>(null);
  final Rx<BookingModel?> currentBooking = Rx<BookingModel?>(null);
  final RxInt timerSeconds = 0.obs;
  final RxBool isTimerRunning = false.obs;
  final RxString errorMessage = ''.obs;
  Timer? _timer;

  Future<void> startSession(BookingModel booking, String? gmeetLink) async {
    errorMessage.value = '';
    currentBooking.value = booking;

    // Kalau tidak ada link yang di-pass, ambil dari session record yang
    // sudah dibuat saat booking (Varian A)
    var link = gmeetLink;
    if (link == null || link.isEmpty) {
      try {
        final sessionRow = await SupabaseService.client
            .from(SupabaseConstants.tableSessions)
            .select('gmeet_link')
            .eq('booking_id', booking.id)
            .maybeSingle();
        link = sessionRow?['gmeet_link'] as String?;
      } catch (_) {}
    }

    final sessionData = {
      'booking_id': booking.id,
      'start_time': DateTime.now().toIso8601String(),
      'status': 'ongoing',
      'gmeet_link': link,
    };

    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableSessions)
          .insert(sessionData)
          .select()
          .single();

      currentSession.value = SessionModel.fromMap(data);

      await SupabaseService.client
          .from(SupabaseConstants.tableBookings)
          .update({'status': 'ongoing'})
          .eq('id', booking.id);

      if (link != null && link.isNotEmpty) {
        await _launchGmeet(link);
      }

      _startTimer();
    } catch (e) {
      print('SessionController.startSession error: $e');
      errorMessage.value = 'Gagal memulai sesi. Coba lagi.';
    }
  }

  Future<void> _launchGmeet(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        errorMessage.value = 'Tidak bisa membuka link Google Meet.';
      }
    } catch (e) {
      print('SessionController._launchGmeet error: $e');
      errorMessage.value = 'Link Google Meet tidak valid.';
    }
  }

  void _startTimer() {
    isTimerRunning.value = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timerSeconds.value++;
    });
  }

  Future<void> endSession() async {
    _timer?.cancel();
    isTimerRunning.value = false;

    final session = currentSession.value;
    if (session != null) {
      try {
        await SupabaseService.client
            .from(SupabaseConstants.tableSessions)
            .update({
              'end_time': DateTime.now().toIso8601String(),
              'status': 'completed',
              'elapsed_seconds': timerSeconds.value,
            })
            .eq('id', session.id);

        await SupabaseService.client
            .from(SupabaseConstants.tableBookings)
            .update({'status': 'completed'})
            .eq('id', session.bookingId);
      } catch (e) {
        print('SessionController.endSession error: $e');
      }
    }

    Get.offNamed(
      AppRoutes.review,
      arguments: {
        'sessionId': currentSession.value?.id,
        'tutorId': currentBooking.value?.tutorId,
        'subject': currentBooking.value?.subject,
      },
    );
  }

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
