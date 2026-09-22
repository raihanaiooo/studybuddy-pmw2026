import 'package:get/get.dart';
import '../models/availability_slot_model.dart';

/// Controller pengaturan slot ketersediaan Tutor (FR-BOOK-01)
///
/// Masih dummy data (contract-first) — tinggal ganti fetch/add/remove
/// dengan query Supabase begitu kontrak BE untuk tabel AvailabilitySlot
/// tersedia.
class TutorScheduleController extends GetxController {
  final RxList<AvailabilitySlotModel> slots = <AvailabilitySlotModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSlots();
  }

  Future<void> fetchSlots() async {
    isLoading.value = true;
    slots.value = _dummySlots;
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    isLoading.value = false;
  }

  /// Tambah slot ketersediaan baru (FR-BOOK-01)
  void addSlot(DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      Get.snackbar('Perhatian', 'Jam selesai harus setelah jam mulai');
      return;
    }
    slots.add(
      AvailabilitySlotModel(
        id: 'slot-${DateTime.now().microsecondsSinceEpoch}',
        tutorId: 'tutor-me',
        startTime: start,
        endTime: end,
      ),
    );
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Hapus slot yang belum dibooking
  void removeSlot(String id) {
    final slot = slots.firstWhereOrNull((s) => s.id == id);
    if (slot != null && slot.status == 'booked') {
      Get.snackbar('Tidak bisa dihapus', 'Slot ini sudah dibooking Buddy');
      return;
    }
    slots.removeWhere((s) => s.id == id);
  }

  static final List<AvailabilitySlotModel> _dummySlots = [
    AvailabilitySlotModel(
      id: 'slot-1',
      tutorId: 'tutor-me',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    ),
    AvailabilitySlotModel(
      id: 'slot-2',
      tutorId: 'tutor-me',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      status: 'booked',
    ),
    AvailabilitySlotModel(
      id: 'slot-3',
      tutorId: 'tutor-me',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
    ),
  ];
}
