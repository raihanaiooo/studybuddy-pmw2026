import 'dart:async';

import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/realtime_service.dart';
import '../core/constants/supabase_constants.dart';
import '../data/availability_slot_repository_supabase.dart';
import '../domain/availability_slot_repository.dart';
import '../domain/booking_refresh_coalescer.dart';
import '../domain/slot_booking_policy.dart';
import '../models/booking_model.dart';
import '../models/availability_slot_model.dart';
import '../models/user_model.dart';
import '../app/routes.dart';

/// Controller untuk pembuatan dan manajemen booking
class BookingController extends GetxController {
  BookingController({AvailabilitySlotRepository? slotRepository})
    : _slots = slotRepository ?? AvailabilitySlotRepositorySupabase();

  final AvailabilitySlotRepository _slots;
  final _authService = AuthService();

  /// Realtime booking (Wave 2.2). Kontrak isi event (C-BOOK-06 / D-52)
  /// belum disepakati BE, jadi event hanya dipakai sebagai sinyal
  /// "ada perubahan" — tidak ada field payload yang dibaca.
  final RealtimeService _realtime = RealtimeService();
  final BookingRefreshCoalescer _bookingRefresh = BookingRefreshCoalescer();

  /// Penjaga agar percobaan langganan tidak berlipat (identity tidak
  /// berubah selama sesi — langganan cukup dipasang sekali).
  bool _subscriptionAttempted = false;

  /// True HANYA bila langganan benar-benar terpasang. Di test tanpa
  /// Supabase (atau saat user belum ada) ini tetap false — tidak ada
  /// sukses palsu.
  bool _realtimeStarted = false;
  bool _disposed = false;

  /// True setelah langganan realtime booking terpasang.
  bool get realtimeSubscribed => _realtimeStarted;

  /// Reset penanda langganan (khusus test — menghindari error
  /// "subscribed twice" saat test yang sama menghidupkan controller ulang).
  void debugResetRealtimeForTest() {
    _subscriptionAttempted = false;
    _realtimeStarted = false;
  }

  final RxList<BookingModel> myBookings = <BookingModel>[].obs;
  final RxList<BookingModel> tutorBookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pilih-slot ala tiket bioskop (FR-BOOK-02/03/04)
  final RxList<AvailabilitySlotModel> availableSlots =
      <AvailabilitySlotModel>[].obs;
  final Rx<AvailabilitySlotModel?> selectedSlot = Rx<AvailabilitySlotModel?>(
    null,
  );
  final RxBool isLoadingSlots = false.obs;

  /// True bila kegagalan slot disebabkan kontrak AvailabilitySlot
  /// (C-SLOT-01..08) belum dijawab Back-End — bukan error transient.
  final RxBool slotContractMissing = false.obs;

  /// Slot mentah dari backend untuk evaluasi aturan (bentuk domain,
  /// terpisah dari model UI).
  List<AvailabilitySlotRef> _slotRefs = const [];

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
    _startBookingRealtime();
  }

  @override
  void onClose() {
    _disposed = true;
    unawaited(_realtime.unsubscribeBookings());
    super.onClose();
  }

  /// Pasang langganan realtime booking milik user yang login (NFR-BOOK-02:
  /// perubahan status terlihat di kedua sisi tanpa refresh manual).
  ///
  /// Langganan adalah peningkatan di atas fetch-on-init yang sudah
  /// terverifikasi: bila identitas belum ada, Supabase belum siap, atau
  /// publikasi realtime belum diaktifkan di backend, aplikasi tetap
  /// berjalan dengan perilaku baca manual — TIDAK ada sukses palsu.
  void _startBookingRealtime() {
    if (_subscriptionAttempted) return;
    _subscriptionAttempted = true;
    () async {
      try {
        final user = await _authService.getCurrentUser();
        if (_disposed || user == null) return;
        // Id user sama untuk kedua sisi relasi terverifikasi pada baris
        // bookings: kolom customer_id (Buddy) dan tutor_id (Tutor).
        _realtime.subscribeBookings(
          customerId: user.id,
          tutorId: user.id,
          onChanged: _onBookingChangeEvent,
        );
        _realtimeStarted = true;
      } catch (_) {
        // Tanpa Supabase (mis. widget test) langganan gagal — dibiarkan
        // senyap karena fetch-on-init tetap berjalan.
      }
    }();
  }

  /// Reaksi terhadap event perubahan booking. Isi event TIDAK diparse
  /// (C-BOOK-06 / D-52 belum dijawab BE): state disegarkan lewat jalur
  /// baca yang sudah terverifikasi, dikoaleskan agar event beruntun
  /// tidak menembak Supabase berulang-ulang.
  void _onBookingChangeEvent() {
    _bookingRefresh.request(_silentRefreshBookings);
  }

  /// Segarkan daftar booking TANPA menyalakan spinner [isLoading] —
  /// status yang sudah terlihat pengguna tidak boleh berkedip tiap
  /// event realtime; kegagalan refresh latar mempertahankan state lama.
  Future<void> _silentRefreshBookings() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || _disposed) return;
      final bookings = await _readRoleScopedBookings(user);
      if (_disposed) return;
      if (user.role == 'tutor') {
        tutorBookings.value = bookings;
      } else {
        myBookings.value = bookings;
      }
    } catch (_) {
      // Refresh latar gagal (jaringan/Supabase) — state sebelumnya
      // dipertahankan; event berikutnya akan mencoba ulang.
    }
  }

  /// Ambil slot ketersediaan nyata milik Tutor (FR-BOOK-02) dari
  /// [AvailabilitySlotRepository]. Slot terbooking dan di luar jendela H-5
  /// disaring lewat [SlotBookingPolicy] sehingga tidak pernah ditawarkan.
  Future<void> fetchAvailableSlots(String tutorId) async {
    isLoadingSlots.value = true;
    selectedSlot.value = null;
    slotContractMissing.value = false;
    errorMessage.value = '';
    try {
      final refs = await _slots.fetchTutorSlots(tutorId);
      _slotRefs = refs;
      final selectable = refs
          .where((s) => SlotBookingPolicy.isSelectableForBooking(s))
          .map(_mapRefToModel)
          .toList();
      availableSlots.value = selectable;
    } on AvailabilitySlotBackendMissingException catch (e) {
      _slotRefs = const [];
      availableSlots.value = [];
      slotContractMissing.value = true;
      // Kontrak slot belum dijawab BE (C-SLOT-01..08) — dilaporkan
      // sebagai kontrak hilang, bukan disamarkan "Tutor belum buka slot".
      errorMessage.value = e.message;
    } catch (e) {
      _slotRefs = const [];
      availableSlots.value = [];
      errorMessage.value = 'Gagal memuat jadwal. Coba lagi.';
    } finally {
      isLoadingSlots.value = false;
    }
  }

  /// Tandai slot yang dipilih Buddy (FR-BOOK-04). Pemilihan UI bukan kunci —
  /// penguncian nyata terjadi server-side saat booking dibuat
  /// (lihat createBooking).
  void selectSlot(AvailabilitySlotModel slot) {
    final ref = _slotRefs.firstWhereOrNull((r) => r.id == slot.id);
    if (ref != null && !SlotBookingPolicy.isSelectableForBooking(ref)) {
      // Slot menjadi tidak valid setelah daftar dimuat (mis. sudah
      // diambil Buddy lain) — abaikan dan segarkan.
      if (ref.status != SlotStatus.available) {
        Get.snackbar('Slot sudah diambil', 'Pilih jadwal lain yang tersedia.');
        fetchAvailableSlots(slot.tutorId);
      }
      return;
    }
    selectedSlot.value = slot;
  }

  /// Fetch booking milik customer/tutor yang sedang login
  Future<void> fetchMyBookings() async {
    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final bookings = await _readRoleScopedBookings(user);

      if (user.role == 'tutor') {
        tutorBookings.value = bookings;
      } else {
        myBookings.value = bookings;
      }
    } catch (e) {
      // Tangani error tanpa crash (mis. belum ada sesi login aktif), tapi
      // tetap catat jejak supaya error jaringan/Supabase asli tidak
      // tersamar diam-diam sebagai "belum ada booking".
      // ignore: avoid_print
      print('BookingController.fetchMyBookings gagal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Baca booking milik [user] sesuai perannya dari tabel bookings.
  /// Kolom filter TERVERIFIKASI oleh kode baca yang sudah berjalan:
  /// `customer_id` untuk Buddy dan `tutor_id` untuk Tutor; bentuk baris
  /// ('*, tutors(*)') tidak diubah. Melempar bila baca gagal — pemanggil
  /// yang memutuskan perlakuan errornya.
  Future<List<BookingModel>> _readRoleScopedBookings(UserModel user) async {
    final column = user.role == 'tutor' ? 'tutor_id' : 'customer_id';

    final data = await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .select('*, tutors(*)')
        .eq(column, user.id)
        .order('session_time', ascending: true);

    return (data as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Buat booking baru dengan validasi H-5 jam dan check-and-book slot
  /// atomik (FR-BOOK-03/04/05).
  Future<void> createBooking({
    required String tutorId,
    required DateTime sessionTime,
    required int durationMinutes,
    required String subject,
    required String sessionType,
    String? notes,
  }) async {
    errorMessage.value = '';
    slotContractMissing.value = false;

    if (!SlotBookingPolicy.isBookingTimeValid(sessionTime)) {
      errorMessage.value = 'Booking minimal 5 jam sebelum sesi dimulai';
      return;
    }

    final slot = selectedSlot.value;
    if (slot == null) {
      errorMessage.value = 'Pilih jadwal terlebih dahulu';
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final bookingValues = {
        'customer_id': user.id,
        'tutor_id': tutorId,
        'session_time': sessionTime.toIso8601String(),
        'duration_minutes': durationMinutes,
        'subject': subject,
        'session_type': sessionType,
        'status': 'confirmed',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      final outcome = await _slots.bookSlot(
        slotId: slot.id,
        bookingValues: bookingValues,
      );

      if (!outcome.success) {
        selectedSlot.value = null;
        Get.snackbar(
          'Slot sudah diambil',
          'Jadwal ini baru saja dibooking Buddy lain. Pilih jadwal lain.',
        );
        await fetchAvailableSlots(tutorId);
        return;
      }

      availableSlots.removeWhere((s) => s.id == slot.id);
      selectedSlot.value = null;

      Get.back();
      Get.snackbar('Berhasil', 'Booking berhasil dibuat!');
      await fetchMyBookings();
    } on AvailabilitySlotBackendMissingException catch (e) {
      slotContractMissing.value = true;
      errorMessage.value = e.message;
      Get.snackbar(
        'Kontrak backend belum tersedia',
        'Booking tidak dibuat — ${e.message}',
      );
    } catch (e) {
      errorMessage.value = 'Gagal membuat booking. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Batalkan booking
  Future<void> cancelBookingAsBuddy(String bookingId) async {
    isLoading.value = true;
    try {
      await updateBookingStatus(bookingId, 'cancelled');
      Get.snackbar('Dibatalkan', 'Booking kamu sudah dibatalkan.');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak bisa membatalkan booking.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Ubah status booking, mis. Tutor konfirmasi ('confirmed') atau tolak
  /// booking masuk ('cancelled') (FR-BOOK-03/09)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .update({'status': status})
        .eq('id', bookingId);
    await fetchMyBookings();
  }

  AvailabilitySlotModel _mapRefToModel(AvailabilitySlotRef ref) =>
      AvailabilitySlotModel(
        id: ref.id,
        tutorId: ref.tutorId,
        startTime: ref.startTime,
        endTime: ref.endTime,
        status: ref.status,
      );
}
