import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/services/supabase_service.dart';
import '../domain/availability_slot_repository.dart';
import '../domain/slot_booking_policy.dart';

/// ═══════════════════ PERINGATAN KONTRAK (ISOLASI ASUMSI) ═══════════════════
///
/// Ini SATU-SATUNYA tempat di kodebase yang mengetahui nama tabel/kolom slot.
/// SRS §4.1 memberi nama entitas & atribut kunci secara *indikatif*
/// (`AvailabilitySlot`: `tutor_id, waktu_mulai, waktu_selesai, status`) dan
/// kode yang berjalan hari ini tidak pernah menyentuh tabel ini, sehingga
/// kontrak C-SLOT-01..08 BELUM TERVERIFIKASI. Nilai di bawah adalah asumsi
/// eksplisit mengikuti penamaan tabel-kolom Bahasa Indonesia yang TERBUKTI
/// dipakai tabel `bookings`/`reviews`/`sessions` yang sudah terpakai —
/// BUKAN kontrak yang dikonfirmasi Back-End.
///
/// Bila asumsi keliru, PostgrestException "relation/column does not exist"
/// akan dibungkus menjadi [AvailabilitySlotBackendMissingException] sehingga
/// pemanggil menandai kontrak hilang alih-alih berpura-pura berhasil.
/// Jawaban resmi C-SLOT-01..08 cukup untuk mengoreksi berkas ini saja.
/// ═══════════════════════════════════════════════════════════════════════════
class AvailabilitySlotRepositorySupabase implements AvailabilitySlotRepository {
  /// ASUMSI (tidak terverifikasi): nama tabel slot. Belum ada konstantanya
  /// di `SupabaseConstants` karena kontraknya belum dijawab.
  static const String _tableSlots = 'availability_slots';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<AvailabilitySlotRef>> fetchTutorSlots(String tutorId) async {
    try {
      final data = await _client
          .from(_tableSlots)
          .select()
          .eq('tutor_id', tutorId)
          .order('waktu_mulai', ascending: true);
      return (data as List)
          .map((e) => _toRef(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<AvailabilitySlotRef> createSlot(AvailabilitySlotDraft draft) async {
    try {
      final data = await _client
          .from(_tableSlots)
          .insert({
            'tutor_id': draft.tutorId,
            'waktu_mulai': draft.startTime.toIso8601String(),
            'waktu_selesai': draft.endTime.toIso8601String(),
            'zona_waktu': draft.timezone,
            'status': SlotStatus.available,
          })
          .select()
          .single();
      return _toRef(data);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    try {
      await _client.from(_tableSlots).delete().eq('id', slotId);
    } on PostgrestException catch (e) {
      throw _wrapMissing(e);
    }
  }

  @override
  Future<BookingSlotOutcome> bookSlot({
    required String slotId,
    required Map<String, dynamic> bookingValues,
  }) async {
    try {
      // Langkah 1 — kunci kondisional di server (FR-BOOK-04): baris slot
      // hanya berpindah available → booked BILA masih available. Dua Buddy
      // yang bersaing menghasilkan tepat satu pemenang.
      final locked = await _client
          .from(_tableSlots)
          .update({'status': SlotStatus.booked})
          .eq('id', slotId)
          .eq('status', SlotStatus.available)
          .select()
          .maybeSingle();
      if (locked == null) {
        return const BookingSlotOutcome.taken();
      }

      // Langkah 2 — tulis booking (bentuk baris bookings TERVERIFIKASI:
      // dipakai createBooking yang sudah berjalan).
      await _client.from(SupabaseConstants.tableBookings).insert(bookingValues);
      return const BookingSlotOutcome.success();
    } on PostgrestException catch (e) {
      // Langkah 3 — kompensasi best-effort: booking gagal ⇒ slot jangan
      // tertinggal terkunci. Transaksi DB penuh bukan bagian kontrak yang
      // bisa diverifikasi dari klien (C-SLOT-05 tetap terbuka).
      try {
        await _client
            .from(_tableSlots)
            .update({'status': SlotStatus.available})
            .eq('id', slotId)
            .eq('status', SlotStatus.booked);
      } on PostgrestException {
        // Tidak ada yang lebih bisa dilakukan klien — biarkan error utama
        // yang naik; slot berpotensi perlu dilepas manual oleh BE.
      }
      throw _wrapMissing(e);
    }
  }

  AvailabilitySlotRef _toRef(Map<String, dynamic> map) => AvailabilitySlotRef(
    id: map['id'] as String,
    tutorId: map['tutor_id'] as String,
    startTime: DateTime.parse(map['waktu_mulai'] as String),
    endTime: DateTime.parse(map['waktu_selesai'] as String),
    status: map['status'] as String? ?? SlotStatus.available,
    timezone: map['zona_waktu'] as String? ?? 'WIB',
  );

  /// Pembungkus tunggal untuk gagal-kenal-skema: semua kegagalan
  /// PostgrestException dari tabel slot dilaporkan sebagai kontrak hilang
  /// (relasi/kolom tidak dikenal) ALIH-ALIH error tak berarah — sehingga
  /// pengujian lapangan langsung menunjuk C-SLOT-01..08 yang harus dijawab.
  AvailabilitySlotBackendMissingException _wrapMissing(PostgrestException e) {
    final m = e.message.toLowerCase();
    final missing =
        m.contains('does not exist') ||
        m.contains('could not find the table') ||
        m.contains('schema cache');
    return missing
        ? AvailabilitySlotBackendMissingException(
          'Kontrak AvailabilitySlot (C-SLOT-01..08) belum terverifikasi: '
          'tabel/kolom "$_tableSlots" tidak dikenal backend. '
          'Minta jawaban kontrak ke pemilik Back-End sebelum lanjut.',
          e,
        )
        : AvailabilitySlotBackendMissingException(
          'Operasi slot gagal (bukan skema): ${e.message}',
          e,
        );
  }
}
