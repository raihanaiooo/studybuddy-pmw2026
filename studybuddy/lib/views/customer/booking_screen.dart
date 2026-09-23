import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/tutor_model.dart';
import '../../models/availability_slot_model.dart';
import '../../models/invoice_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../app/routes.dart';

/// Screen booking: pilih mata kuliah, tipe sesi, dan slot waktu tersedia
/// milik Tutor (FR-BOOK-01..04 — model pilih-langsung ala tiket bioskop)
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _notesCtrl = TextEditingController();
  String? _subject;
  String _sessionType = 'video';
  TutorModel? _tutor;

  @override
  void initState() {
    super.initState();
    // Dipanggil di initState (bukan ditunda ke postFrameCallback dalam
    // build()) supaya frame pertama tidak sempat menampilkan state
    // "belum ada slot" yang keliru sebelum data sungguhan masuk.
    final tutor = Get.arguments as TutorModel?;
    if (tutor != null) {
      _tutor = tutor;
      _subject = tutor.subjects.isNotEmpty ? tutor.subjects.first : null;
      Get.find<BookingController>().fetchAvailableSlots(tutor.id);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingController>();
    final tutor = _tutor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        title: Text(
          'Booking Tutor',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tutor != null) _tutorCard(tutor),

            // Mata Kuliah
            _sectionTitle('Mata Kuliah'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (tutor?.subjects ?? const [])
                  .map(
                    (s) => ChoiceChip(
                      label: Text(s),
                      selected: _subject == s,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: _subject == s
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) => setState(() => _subject = s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Tipe sesi
            _sectionTitle('Tipe Sesi'),
            Row(
              children: [
                _sessionTypeChip('video', '📹 Via Google Meet'),
                const SizedBox(width: 10),
                _sessionTypeChip('chat', '💬 Via Chat'),
              ],
            ),
            const SizedBox(height: 20),

            // Pilih slot (referensi: tiket bioskop online — FR-BOOK-02)
            _sectionTitle('Pilih Jadwal'),
            const SizedBox(height: 4),
            Obx(() {
              if (ctrl.isLoadingSlots.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                );
              }
              final hasAvailableSlot = ctrl.availableSlots.any(
                (s) => s.status == 'available',
              );
              if (ctrl.slotContractMissing.value) {
                // Kontrak AvailabilitySlot (C-SLOT-01..08) belum dijawab
                // Back-End — tampilkan apa adanya, jangan samakan dengan
                // "Tutor belum membuka slot".
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    ctrl.errorMessage.value,
                    style: AppTextStyles.caption,
                  ),
                );
              }
              if (!hasAvailableSlot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Tutor belum membuka slot ketersediaan.',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return _buildSlotPicker(ctrl);
            }),
            const SizedBox(height: 20),

            // Catatan opsional
            _sectionTitle('Catatan (Opsional)'),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: _inputDeco(
                'Ceritakan topik yang ingin dipelajari...',
              ),
            ),
            const SizedBox(height: 28),

            // Error
            Obx(
              () => ctrl.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        ctrl.errorMessage.value,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),

            // Submit button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      ctrl.isLoading.value ||
                          tutor == null ||
                          ctrl.selectedSlot.value == null ||
                          _subject == null
                      ? null
                      : () => _goToInvoice(tutor, ctrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: ctrl.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Konfirmasi Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buat invoice untuk sesi yang dipilih, lalu arahkan ke pembayaran.
  /// Booking baru benar-benar dibuat (createBooking) begitu invoice
  /// Lunas — lihat onPaid di bawah (FR-PAY-08).
  void _goToInvoice(TutorModel tutor, BookingController ctrl) {
    final slot = ctrl.selectedSlot.value!;
    final durationMinutes = slot.endTime.difference(slot.startTime).inMinutes;
    final auth = Get.find<AuthController>();
    final paymentCtrl = Get.find<PaymentController>();
    final user = auth.currentUser.value;
    final price = tutor.pricePerHour * durationMinutes / 60;

    paymentCtrl.generateInvoice(
      tutorName: tutor.fullName,
      studentName: user?.fullName ?? 'Buddy',
      studentGrade: user?.jenjang ?? '-',
      studentSchool: '-',
      sessions: [
        InvoiceSessionItem(
          subject: _subject!,
          sessionDate: slot.startTime,
          startTime: AppDateUtils.formatTime(slot.startTime),
          endTime: AppDateUtils.formatTime(slot.endTime),
          timezone: slot.timezone,
          price: price,
        ),
      ],
      onPaid: () => ctrl.createBooking(
        tutorId: tutor.id,
        sessionTime: slot.startTime,
        durationMinutes: durationMinutes,
        subject: _subject!,
        sessionType: _sessionType,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      ),
    );

    Get.toNamed(AppRoutes.invoice);
  }

  Widget _tutorCard(TutorModel tutor) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.08),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.blueLight],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            tutor.fullName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tutor.fullName, style: AppTextStyles.heading3),
            Text(
              tutor.subjects.take(2).join(' · '),
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    ),
  );

  /// Slot dikelompokkan per tanggal, ditampilkan sebagai kartu jam yang
  /// bisa langsung dipilih-tap (FR-BOOK-02).
  Widget _buildSlotPicker(BookingController ctrl) {
    final byDate = <String, List<AvailabilitySlotModel>>{};
    // Slot yang sudah 'booked' tidak boleh muncul sebagai pilihan
    // (FR-BOOK-04) — nggak cukup diandalkan dari data belum terpakai.
    for (final slot in ctrl.availableSlots.where(
      (s) => s.status == 'available',
    )) {
      final key = AppDateUtils.formatDate(slot.startTime);
      byDate.putIfAbsent(key, () => []).add(slot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: byDate.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: entry.value.map((slot) {
                  final selected = ctrl.selectedSlot.value?.id == slot.id;
                  return GestureDetector(
                    key: ValueKey('slot-${slot.id}'),
                    onTap: () => ctrl.selectSlot(slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        AppDateUtils.formatTime(slot.startTime),
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: AppTextStyles.bodySemiBold.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _sessionTypeChip(String type, String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _sessionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _sessionType == type ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _sessionType == type
                ? AppColors.primaryBlue
                : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: _sessionType == type
                ? Colors.white
                : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.caption,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
