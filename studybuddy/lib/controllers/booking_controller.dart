import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../core/services/auth_service.dart';
import '../core/constants/supabase_constants.dart';
import '../data/availability_slot_repository_supabase.dart';
import '../domain/availability_slot_repository.dart';
import '../domain/slot_booking_policy.dart';
import '../models/booking_model.dart';
import '../models/availability_slot_model.dart';
import '../app/routes.dart';

/// Controller untuk pembuatan dan manajemen booking
class BookingController extends GetxController {
  BookingController({AvailabilitySlotRepository? slotRepository})
    : _slots = slotRepository ?? AvailabilitySlotRepositorySupabase();

  final AvailabilitySlotRepository _slots;
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

    // Validasi waktu minimal H-5 jam (aturan domain, SRS)
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

      // Barisan booking: bentuk kolom TERVERIFIKASI dari kode yang berjalan —
      // TIDAK ada kolom slot ditambahkan (hubungan slot↔booking adalah
      // kontrak C-SLOT-07 yang belum dijawab).
      final bookingValues = {
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

      // FR-BOOK-04: kunci kondisional server-side — slot hanya berpindah
      // available → booked bila masih available, lalu booking ditulis.
      // Dua Buddy yang bersaing menghasilkan tepat satu pemenang.
      final outcome = await _slots.bookSlot(
        slotId: slot.id,
        bookingValues: bookingValues,
      );

      if (!outcome.success) {
        // Slot sudah diambil Buddy lain — jangan buat booking palsu.
        selectedSlot.value = null;
        Get.snackbar(
          'Slot sudah diambil',
          'Jadwal ini baru saja dibooking Buddy lain. Pilih jadwal lain.',
        );
        await fetchAvailableSlots(tutorId);
        return;
      }

      // FR-BOOK-05: slot keluar dari daftar tersedia begitu booking dibuat
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
        'Booking tidak dibuat — kontrak AvailabilitySlot (C-SLOT-01..08) '
        'belum dijawab pemilik Back-End.',
      );
    } catch (e) {
      errorMessage.value = 'Gagal membuat booking. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Batalkan booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
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
        timezone: ref.timezone,
      );
}
