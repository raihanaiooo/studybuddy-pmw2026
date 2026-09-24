import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../data/availability_slot_repository_supabase.dart';
import '../domain/availability_slot_repository.dart';
import '../domain/slot_booking_policy.dart';
import 'auth_controller.dart';

/// Controller pengaturan slot ketersediaan Tutor (FR-BOOK-01).
///
/// Persisten: slot dibaca/ditulis ke backend lewat
/// [AvailabilitySlotRepository] (batas domain) — bukan lagi daftar in-memory.
/// Kontrak AvailabilitySlot (C-SLOT-01..08) BELUM terverifikasi; semua
/// asumsi nama tabel/kolom terisolasi di implementasi data, dan kegagalan
/// skema dilaporkan sebagai [AvailabilitySlotBackendMissingException].
class TutorScheduleController extends GetxController {
  TutorScheduleController({AvailabilitySlotRepository? slotRepository})
    : _slots = slotRepository ?? AvailabilitySlotRepositorySupabase();

  final AvailabilitySlotRepository _slots;
  final _authService = AuthService();

  final RxList<AvailabilitySlotRef> slots = <AvailabilitySlotRef>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String? _tutorId;

  @override
  void onInit() {
    super.onInit();
    fetchSlots();
  }

  /// Slot milik Tutor yang sedang login — identitas dari state user aplikasi
  /// (AuthController.currentUser, pola yang sama dipakai view booking),
  /// dengan fallback pembacaan Supabase, bukan lagi hardcode 'tutor-me'.
  Future<void> fetchSlots() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final tutorId = await _resolveTutorId();
      if (tutorId == null) return;
      _tutorId = tutorId;
      final data = await _slots.fetchTutorSlots(tutorId);
      slots.value = data;
    } on AvailabilitySlotBackendMissingException catch (e) {
      slots.value = [];
      // Kontrak slot belum dijawab BE (C-SLOT-01..08) — diberi tahu
      // apa adanya, bukan disamarkan sebagai "belum ada slot".
      errorMessage.value = e.message;
    } catch (e) {
      // Gagal jaringan/autentikasi — jangan samakan dengan "kontrak hilang".
      errorMessage.value = 'Gagal memuat slot ketersediaan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Identitas Tutor: state user aplikasi dulu (terisi saat splash),
  /// fallback ke pembacaan Supabase bila state belum terisi.
  Future<String?> _resolveTutorId() async {
    if (Get.isRegistered<AuthController>()) {
      final user = Get.find<AuthController>().currentUser.value;
      if (user != null) return user.id;
    }
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  /// Tambah slot ketersediaan baru (FR-BOOK-01) — aturan bisnis
  /// (validitas waktu, H-5) ada di domain, bukan di controller.
  Future<void> addSlot(DateTime start, DateTime end) async {
    if (!end.isAfter(start)) {
      Get.snackbar('Perhatian', 'Jam selesai harus setelah jam mulai');
      return;
    }
    final tutorId = _tutorId;
    if (tutorId == null) {
      Get.snackbar('Gagal', 'Identitas Tutor tidak dikenali. Coba lagi.');
      return;
    }
    errorMessage.value = '';
    try {
      final created = await _slots.createSlot(
        AvailabilitySlotDraft(tutorId: tutorId, startTime: start, endTime: end),
      );
      slots.add(created);
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    } on AvailabilitySlotBackendMissingException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Kontrak backend belum tersedia', 'Slot tidak disimpan.');
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan slot. Coba lagi.';
    }
  }

  /// Hapus slot yang belum dibooking (aturan SRS: slot terbooking tidak
  /// boleh dihapus — diberlakukan lewat [SlotBookingPolicy]).
  Future<void> removeSlot(String id) async {
    final slot = slots.firstWhereOrNull((s) => s.id == id);
    if (slot != null && !SlotBookingPolicy.isRemovableByTutor(slot)) {
      Get.snackbar('Tidak bisa dihapus', 'Slot ini sudah dibooking Buddy');
      return;
    }
    errorMessage.value = '';
    try {
      await _slots.deleteSlot(id);
      slots.removeWhere((s) => s.id == id);
    } on AvailabilitySlotBackendMissingException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Kontrak backend belum tersedia', 'Slot tidak dihapus.');
    } catch (e) {
      errorMessage.value = 'Gagal menghapus slot. Coba lagi.';
    }
  }
}
