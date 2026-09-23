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

/// Buddy cancel booking (FR-BOOK-08).
/// Refund logic sepenuhnya menunggu keputusan client soal threshold.
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
