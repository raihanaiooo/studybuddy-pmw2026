import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/package_controller.dart';
import '../../models/tutor_model.dart';
import '../../models/availability_slot_model.dart';
import '../../models/invoice_model.dart';
import '../../models/token_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../app/routes.dart';

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
  TokenModel? _availableToken;
  bool _useToken = false;

  @override
  void initState() {
    super.initState();
    final tutor = Get.arguments as TutorModel?;
    if (tutor != null) {
      _tutor = tutor;
      _subject = tutor.subjects.isNotEmpty ? tutor.subjects.first : null;
      Get.find<BookingController>().fetchAvailableSlots(tutor.id);
      _loadToken();
    }
  }

  Future<void> _loadToken() async {
    final packageCtrl = Get.find<PackageController>();
    final token = await packageCtrl.pickTokenForBooking();
    if (mounted) {
      setState(() => _availableToken = token);
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

            _sectionTitle('Tipe Sesi'),
            Row(
              children: [
                _sessionTypeChip('video', '📹 Via Google Meet'),
                const SizedBox(width: 10),
                _sessionTypeChip('chat', '💬 Via Chat'),
              ],
            ),
            const SizedBox(height: 20),

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

            // Pilihan metode bayar (kalau ada token)
            if (_availableToken != null) ...[
              _sectionTitle('Metode Pembayaran'),
              const SizedBox(height: 4),
              _buildPaymentOptions(tutor),
              const SizedBox(height: 20),
            ],

            _sectionTitle('Catatan (Opsional)'),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: _inputDeco(
                'Ceritakan topik yang ingin dipelajari...',
              ),
            ),
            const SizedBox(height: 28),

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
                      : () => _submit(tutor, ctrl),
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
                      : Text(
                          _useToken
                              ? 'Konfirmasi dengan Token'
                              : 'Konfirmasi Booking',
                          style: const TextStyle(
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

  Widget _buildPaymentOptions(TutorModel? tutor) {
    final slot = Get.find<BookingController>().selectedSlot.value;
    final durationMinutes = slot != null
        ? slot.endTime.difference(slot.startTime).inMinutes
        : 60;
    final price = (tutor?.pricePerHour ?? 0) * durationMinutes / 60;

    return Column(
      children: [
        // Opsi 1: Pakai Token
        GestureDetector(
          onTap: () => setState(() => _useToken = true),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _useToken
                  ? AppColors.primaryBlue.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _useToken ? AppColors.primaryBlue : AppColors.border,
                width: _useToken ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _useToken,
                  onChanged: (v) => setState(() => _useToken = v ?? false),
                  activeColor: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pakai Token',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sisa ${_availableToken!.sessionsRemaining} sesi · '
                        'Berlaku ${_availableToken!.daysLeft} hari lagi',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Opsi 2: Bayar Normal
        GestureDetector(
          onTap: () => setState(() => _useToken = false),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: !_useToken
                  ? AppColors.primaryBlue.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: !_useToken ? AppColors.primaryBlue : AppColors.border,
                width: !_useToken ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _useToken,
                  onChanged: (v) => setState(() => _useToken = v ?? false),
                  activeColor: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayar Normal (QRIS)',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp${price.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit(TutorModel tutor, BookingController ctrl) async {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    if (user != null && user.needsParentConsent) {
      Get.snackbar(
        'Persetujuan Diperlukan',
        'Persetujuan orang tua diperlukan. Hubungi admin untuk melengkapi data orang tua/wali.',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final slot = ctrl.selectedSlot.value!;
    final durationMinutes = slot.endTime.difference(slot.startTime).inMinutes;

    // Kalau pakai token → langsung createBooking tanpa payment
    if (_useToken && _availableToken != null) {
      await ctrl.createBooking(
        tutorId: tutor.id,
        sessionTime: slot.startTime,
        durationMinutes: durationMinutes,
        subject: _subject!,
        sessionType: _sessionType,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        useToken: true,
        tokenId: _availableToken!.id,
      );
      // Refresh daftar token
      await Get.find<PackageController>().refreshTokens();
      return;
    }

    // Bayar normal → generate invoice
    final paymentCtrl = Get.find<PaymentController>();
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

  Widget _buildSlotPicker(BookingController ctrl) {
    final byDate = <String, List<AvailabilitySlotModel>>{};
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
