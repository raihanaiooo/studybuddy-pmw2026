import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/auth_service.dart';
import '../core/constants/supabase_constants.dart';
import '../core/utils/date_utils.dart';
import '../models/booking_model.dart';
import '../models/availability_slot_model.dart';
import '../app/routes.dart';

/// Controller untuk pembuatan dan manajemen booking
class BookingController extends GetxController {
  final _authService = AuthService();

  final RxList<BookingModel> myBookings = <BookingModel>[].obs;
  final RxList<BookingModel> tutorBookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pilih-slot ala tiket bioskop (FR-BOOK-02/03/04)
  final RxList<AvailabilitySlotModel> availableSlots =
      <AvailabilitySlotModel>[].obs;
  final Rx<AvailabilitySlotModel?> selectedSlot =
      Rx<AvailabilitySlotModel?>(null);
  final RxBool isLoadingSlots = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  /// Ambil slot ketersediaan milik Tutor tertentu (dummy, contract-first —
  /// tinggal ganti dengan query tabel AvailabilitySlot begitu kontrak BE
  /// modul Booking tersedia).
  Future<void> fetchAvailableSlots(String tutorId) async {
    isLoadingSlots.value = true;
    selectedSlot.value = null;
    // Delay simulasi network — tanpa ini fungsinya sepenuhnya sinkron
    // sehingga state loading tidak pernah benar-benar teramati/teruji.
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    availableSlots.value = List.generate(6, (i) {
      final day = i ~/ 2; // 2 slot per hari, 3 hari ke depan
      final hour = 9 + (i % 2) * 3;
      final start = DateTime(
        now.year,
        now.month,
        now.day + day + 1,
        hour,
      );
      return AvailabilitySlotModel(
        id: 'slot-$tutorId-$i',
        tutorId: tutorId,
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      );
    }).where((s) => AppDateUtils.isBookingTimeValid(s.startTime)).toList();
    isLoadingSlots.value = false;
  }

  /// Kunci slot yang sedang dipilih Buddy agar tidak bisa dipilih Buddy
  /// lain secara bersamaan (FR-BOOK-04 — simulasi lokal untuk MVP UI).
  void selectSlot(AvailabilitySlotModel slot) {
    selectedSlot.value = slot;
  }

  /// Fetch booking milik customer/tutor yang sedang login
  Future<void> fetchMyBookings() async {
    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

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
    } catch (_) {
      // Tangani error tanpa crash (mis. belum ada sesi login aktif)
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

      await SupabaseService.client
          .from(SupabaseConstants.tableBookings)
          .insert(booking);

      // FR-BOOK-05: slot dihapus dari daftar tersedia begitu terkonfirmasi
      final slot = selectedSlot.value;
      if (slot != null) {
        availableSlots.removeWhere((s) => s.id == slot.id);
        selectedSlot.value = null;
      }

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
    await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
    await fetchMyBookings();
  }
}
