import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/auth_service.dart';
import '../core/constants/supabase_constants.dart';
import '../core/utils/date_utils.dart';
import '../models/booking_model.dart';
import '../core/constants/prototype.dart';
import '../core/services/mock_service.dart';

/// Controller untuk pembuatan dan manajemen booking
class BookingController extends GetxController {
  final _authService = AuthService();

  final RxList<BookingModel> myBookings = <BookingModel>[].obs;
  final RxList<BookingModel> tutorBookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  /// Fetch booking milik customer/tutor yang sedang login
  Future<void> fetchMyBookings() async {
    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      if (kUseMock) {
        final list = await MockService.fetchBookingsForUser(
          user.id,
          role: user.role,
        );
        final bookings = list.map((e) => BookingModel.fromMap(e)).toList();
        if (user.role == 'tutor') {
          tutorBookings.value = bookings;
        } else {
          myBookings.value = bookings;
        }
        return;
      }

      final column = user.role == 'tutor' ? 'tutor_id' : 'customer_id';

      final data = await SupabaseService.client
          .from(SupabaseConstants.tableBookings)
          .select('*, tutors(*)')
          .eq(column, user.id)
          .order('session_time', ascending: true);

      final bookings = (data as List)
          .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
          .toList();

      if (user.role == 'tutor') {
        tutorBookings.value = bookings;
      } else {
        myBookings.value = bookings;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Buat booking baru dengan validasi H-5 jam
  Future<void> createBooking({
    required String tutorId,
    required DateTime sessionTime,
    required int durationMinutes,
    required String subject,
    required String sessionType,
    String? notes,
  }) async {
    errorMessage.value = '';

    // Validasi waktu minimal H-5 jam
    if (!AppDateUtils.isBookingTimeValid(sessionTime)) {
      errorMessage.value = 'Booking minimal 5 jam sebelum sesi dimulai';
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final booking = {
        'customer_id': user.id,
        'tutor_id': tutorId,
        'session_time': sessionTime.toIso8601String(),
        'duration_minutes': durationMinutes,
        'subject': subject,
        'session_type': sessionType,
        'status': 'pending',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (kUseMock) {
        final rec = await MockService.createBooking(booking);
        // Update local list
        myBookings.insert(0, BookingModel.fromMap(rec));
        Get.back();
        Get.snackbar('Berhasil', 'Booking berhasil dibuat (mock)');
        return;
      }

      await SupabaseService.client
          .from(SupabaseConstants.tableBookings)
          .insert(booking);

      Get.back();
      Get.snackbar('Berhasil', 'Booking berhasil dibuat!');
      await fetchMyBookings();
    } catch (e) {
      errorMessage.value = 'Gagal membuat booking. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Batalkan booking
  Future<void> cancelBooking(String bookingId) async {
    if (kUseMock) {
      await MockService.cancelBooking(bookingId);
      await fetchMyBookings();
      return;
    }

    await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
    await fetchMyBookings();
  }
}
