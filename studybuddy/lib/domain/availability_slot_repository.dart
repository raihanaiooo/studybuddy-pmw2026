import 'slot_booking_policy.dart' show AvailabilitySlotRef;

/// Kontrak penyimpanan slot ketersediaan — batas domain/aplikasi.
///
/// Implementasi konkret ada di `lib/data/availability_slot_repository_supabase.dart`
/// (arsitektur: antarmuka repository di batas domain, implementasi di data).
///
/// ═══════════════════ STATUS KONTRAK BACKEND (WAJIB DIBACA) ═══════════════════
///
/// * Tabel slot TIDAK PERNAH dirujuk oleh kode klien mana pun sebelum
///   sub-gelombang Wave 2.1 ini — tidak ada konstanta tabelnya di
///   `SupabaseConstants` — sehingga keberadaan tabel dan nama kolomnya
///   BELUM TERVERIFIKASI. Ini bukan kontrak terverifikasi (2) dan bukan teks
///   SRS (1); SRS §4.1 hanya memberi nama entitas `AvailabilitySlot`
///   (`tutor_id, waktu_mulai, waktu_selesai, status`) sebagai indikatif.
/// * Karena itu seluruh akses slot terpusat DI ANTARMUKA INI. Nama tabel/
///   kolom di implementasi data adalah ASUMSI EKSPLISIT yang terisolasi di
///   satu tempat dan siap dikoreksi begitu pemilik Back-End menjawab
///   C-SLOT-01..08.
/// * Saat backend membuktikan asumsi keliru (tabel/kolom tidak dikenal),
///   implementasi melempar [AvailabilitySlotBackendMissingException] —
///   pemanggil menandai kontrak sebagai HILANG, bukan berpura-pura berhasil
///   atau mengganti data dengan dummy.
/// ════════════════════════════════════════════════════════════════════════════
abstract class AvailabilitySlotRepository {
  /// Slot milik satu Tutor, terurut naik berdasarkan waktu mulai.
  Future<List<AvailabilitySlotRef>> fetchTutorSlots(String tutorId);

  /// Membuat slot baru milik Tutor (FR-BOOK-01). Mengembalikan slot seperti
  /// yang tersimpan di backend (termasuk id yang ditetapkan backend).
  Future<AvailabilitySlotRef> createSlot(AvailabilitySlotDraft draft);

  /// Menghapus slot milik Tutor (FR-BOOK-01). Aturan "slot terbooking tidak
  /// boleh dihapus" diberlakukan pemanggil lewat `SlotBookingPolicy`.
  Future<void> deleteSlot(String slotId);

  /// Check-and-book atomik selama backend mendukungnya (FR-BOOK-04):
  ///
  /// 1. Slot hanya berpindah `available` → `booked` BILA masih `available`
  ///    (update kondisional di server) — dua Buddy yang bersaing menghasilkan
  ///    tepat satu pemenang.
  /// 2. Bila slot terkunci, booking ditulis (bentuk baris bookings adalah
  ///    kontrak TERVERIFIKASI — dipakai kode yang berjalan hari ini).
  /// 3. Bila penulisan booking gagal, slot dikembalikan ke `available`
  ///    (kompensasi best-effort — transaksi DB penuh bukan bagian dari
  ///    kontrak yang bisa diverifikasi dari sisi klien; lihat C-SLOT-05).
  ///
  /// Mengembalikan [BookingSlotOutcome.taken] bila slot sudah diambil Buddy
  /// lain; melempar exception bila operasi gagal karena alasan lain.
  Future<BookingSlotOutcome> bookSlot({
    required String slotId,
    required Map<String, dynamic> bookingValues,
  });
}

/// Data slot baru yang akan dibuat — id ditetapkan oleh backend.
class AvailabilitySlotDraft {
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;

  /// Nilai tampilan milik UI (zona waktu slot adalah keputusan terbuka C-X-05).
  final String timezone;

  const AvailabilitySlotDraft({
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.timezone = 'WIB',
  });
}

/// Alasan kegagalan check-and-book yang bersifat aturan (bukan error teknis).
enum BookingSlotFailureReason {
  /// Slot sudah dikunci Buddy lain pada saat yang hampir bersamaan.
  taken,
}

/// Hasil [AvailabilitySlotRepository.bookSlot].
class BookingSlotOutcome {
  final bool success;
  final BookingSlotFailureReason? failureReason;

  const BookingSlotOutcome._(this.success, this.failureReason);

  const BookingSlotOutcome.success() : this._(true, null);

  const BookingSlotOutcome.taken() : this._(false, BookingSlotFailureReason.taken);
}

/// Backend membuktikan kontrak AvailabilitySlot belum ada (tabel/kolom
/// tidak dikenal schema cache). Kontrak C-SLOT-01..08 tetap TERBUKA —
/// exception ini menandai keadaan, bukan menjawabnya.
class AvailabilitySlotBackendMissingException implements Exception {
  final String message;
  final Object? cause;

  const AvailabilitySlotBackendMissingException(this.message, [this.cause]);

  @override
  String toString() =>
      'AvailabilitySlotBackendMissingException: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}
