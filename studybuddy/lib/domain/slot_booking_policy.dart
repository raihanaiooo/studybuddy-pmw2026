/// Aturan bisnis slot & booking (FR-BOOK-01..05) — lapisan domain.
///
/// Berkas ini murni Dart: tanpa Flutter, Supabase, atau HTTP, agar aturan
/// bisa diuji independen (arsitektur: domain tidak bergantung framework).
///
/// Klasifikasi kontrak tiap aturan (wajib dibaca sebelum mengubah):
///  * (1) SRS eksplisit — jendela minimum H-5 jam; slot `booked` tidak bisa
///    dipilih; slot terkunci dari daftar tersedia saat terkonfirmasi;
///    sesi berlangsung dari waktu mulai terjadwal; slot yang sudah dibooking
///    tidak boleh dihapus Tutor.
///  * (3) Inferensi kode — durasi sesi mengikuti lebar slot (dipakai UI).
///  * (4) Belum terselesaikan — nilai status `terkunci` (C-SLOT-03), TTL
///    reservasi (D-40), dan zona waktu (C-X-05) adalah keputusan/ kontrak
///    terbuka; aturan di sini sengaja TIDAK mengasumsikan jawabannya.
library;

/// Nilai status slot yang dipakai klien saat ini (wire value, terverifikasi
/// dari model & UI yang berjalan).
///
/// SRS §4.1 juga menyebut `terkunci` (C-SLOT-03) — pemetaannya belum ada dan
/// karenanya TIDAK direpresentasikan di sini; keputusan D-40/C-SLOT-03 masih
/// terbuka dan tidak boleh diisi sendiri.
abstract final class SlotStatus {
  static const String available = 'available';
  static const String booked = 'booked';
}

/// Referensi data slot minimum yang dibutuhkan aturan bisnis.
///
/// Sengaja dipisahkan dari model lapisan data (`AvailabilitySlotModel`)
/// supaya aturan domain tidak bergantung pada bentuk tabel — kontrak
/// AvailabilitySlot (C-SLOT-01) sendiri belum terverifikasi.
class AvailabilitySlotRef {
  final String id;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  /// Nilai tampilan milik UI; keputusan zona waktu backend adalah C-X-05
  /// (terbuka) — tidak dipakai oleh aturan mana pun di berkas ini.
  final String timezone;

  const AvailabilitySlotRef({
    required this.id,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.status = SlotStatus.available,
    this.timezone = 'WIB',
  });
}

/// Aturan slot & booking yang dipakai bersama oleh sisi Buddy (pemilihan,
/// pembuatan booking) dan sisi Tutor (pengelolaan slot).
abstract final class SlotBookingPolicy {
  /// Jendela minimum pemesanan (SRS: "minimal 5 jam sebelum sesi").
  static const Duration minimumLeadTime = Duration(hours: 5);

  /// (1) SRS: booking minimal H-5 jam sebelum sesi dimulai.
  ///
  /// `now` disuntikkan agar aturan deterministik dan bisa diuji.
  static bool isBookingTimeValid(DateTime sessionTime, {DateTime? now}) {
    final nowDt = now ?? DateTime.now();
    return sessionTime.isAfter(nowDt.add(minimumLeadTime));
  }

  /// (1) SRS: slot hanya bisa dipilih Buddy saat masih `available` DAN di
  /// dalam jendela H-5. Pemilihan ini bukan kunci — penguncian nyata
  /// terjadi saat booking dibuat (lihat `AvailabilitySlotRepository.bookSlot`).
  static bool isSelectableForBooking(AvailabilitySlotRef slot, {DateTime? now}) =>
      slot.status == SlotStatus.available &&
      isBookingTimeValid(slot.startTime, now: now);

  /// (1) SRS FR-BOOK-05: hanya slot yang masih `available` yang boleh
  /// dikonsumsi (ditransisikan menjadi terbooking) oleh sebuah booking.
  static bool isSlotConsumableByBooking(AvailabilitySlotRef slot) =>
      slot.status == SlotStatus.available;

  /// (3) Inferensi dari kode/UI saat ini: durasi sesi mengikuti lebar slot.
  static int sessionDurationMinutes(AvailabilitySlotRef slot) =>
      slot.endTime.difference(slot.startTime).inMinutes;

  /// (1) SRS FR-SESI-01/06: sesi berlangsung mulai dari waktu mulai
  /// terjadwal (dipakai untuk gerbang sesi/chat pada gelombang berikutnya).
  static bool isSessionStarted(AvailabilitySlotRef slot, {DateTime? now}) {
    final nowDt = now ?? DateTime.now();
    return !slot.startTime.isAfter(nowDt);
  }

  /// (1) SRS FR-BOOK-01/04: slot yang sudah dibooking tidak boleh dihapus
  /// Tutor (dipakai juga untuk menahan penghapusan di sisi Tutor).
  static bool isRemovableByTutor(AvailabilitySlotRef slot) =>
      slot.status != SlotStatus.booked;
}
