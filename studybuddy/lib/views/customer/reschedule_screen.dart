import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reschedule_controller.dart';
import '../../models/booking_model.dart';
import '../../models/reschedule_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';

/// Pengajuan reschedule sesi (FR-RESCH-01..09)
class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  final _reasonCtrl = TextEditingController();
  DateTime? _newDate;
  TimeOfDay? _newTime;
  bool _switchTutor = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  DateTime? get _newSessionTime {
    if (_newDate == null || _newTime == null) return null;
    return DateTime(
      _newDate!.year,
      _newDate!.month,
      _newDate!.day,
      _newTime!.hour,
      _newTime!.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RescheduleController>();
    final booking = Get.arguments as BookingModel?;

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.blueDark,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: Get.back,
          ),
        ),
        body: Center(
          child: Text('Booking tidak ditemukan', style: AppTextStyles.caption),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
        title: Text(
          'Ajukan Reschedule',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _originalScheduleCard(booking),
            const SizedBox(height: 16),
            _rulesBanner(ctrl),
            const SizedBox(height: 20),

            _sectionTitle('Alasan Reschedule'),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: _inputDeco(
                'Ceritakan alasan kamu ingin reschedule...',
              ),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Tanggal Baru'),
            GestureDetector(
              onTap: () => _pickDate(booking.sessionTime),
              child: _dateTimeDisplay(
                _newDate != null
                    ? AppDateUtils.formatDate(_newDate!)
                    : 'Pilih tanggal',
                Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Jam Baru'),
            GestureDetector(
              onTap: _pickTime,
              child: _dateTimeDisplay(
                _newTime != null ? _newTime!.format(context) : 'Pilih jam',
                Icons.access_time_outlined,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _switchTutor,
              onChanged: (v) => setState(() => _switchTutor = v),
              activeThumbColor: AppColors.primaryBlue,
              title: Text(
                'Alihkan ke Tutor lain',
                style: AppTextStyles.bodySemiBold,
              ),
              subtitle: Text(
                'Kalau Tutor asli tidak bisa di jadwal baru (FR-RESCH-07)',
                style: AppTextStyles.caption,
              ),
            ),
            const SizedBox(height: 8),

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

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _submit(context, ctrl, booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ajukan Reschedule',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _originalScheduleCard(BookingModel booking) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.08),
          blurRadius: 8,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal Semula', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(booking.subject, style: AppTextStyles.heading3),
        const SizedBox(height: 2),
        Text(
          AppDateUtils.formatDateTime(booking.sessionTime),
          style: AppTextStyles.body,
        ),
      ],
    ),
  );

  Widget _rulesBanner(RescheduleController ctrl) => Obx(
    () => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryBlue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aturan Reschedule:',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Ajukan maksimal H-${RescheduleController.thresholdHours} jam sebelum sesi\n'
                  '• Jadwal baru maks ${RescheduleController.maxPostponeDays} hari dari jadwal semula\n'
                  '• Kuota maksimal ${RescheduleController.maxRescheduleCount}x\n'
                  '• Wajib persetujuan Admin',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ctrl.quotaLeft.value > 0
                        ? AppColors.primaryBlue.withOpacity(0.15)
                        : AppColors.primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sisa kuota: ${ctrl.quotaLeft.value}x',
                    style: AppTextStyles.caption.copyWith(
                      color: ctrl.quotaLeft.value > 0
                          ? AppColors.primaryBlue
                          : AppColors.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDate(DateTime originalSessionTime) async {
    final now = DateTime.now();
    // Kalau sesi aslinya sudah lewat (booking lama yang statusnya masih
    // 'confirmed'), jadwal semula + maxPostponeDays bisa jatuh SEBELUM
    // `now` — showDatePicker mewajibkan lastDate >= firstDate, jadi
    // di-clamp minimal `now` supaya tidak assertion-crash.
    final maxAllowed = originalSessionTime.add(
      const Duration(days: RescheduleController.maxPostponeDays),
    );
    final lastDate = maxAllowed.isAfter(now) ? maxAllowed : now;
    final preferredInitial = now.add(const Duration(days: 1));
    final initialDate = preferredInitial.isAfter(lastDate)
        ? lastDate
        : preferredInitial;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _newDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _newTime = picked);
  }

  void _submit(
    BuildContext context,
    RescheduleController ctrl,
    BookingModel booking,
  ) {
    if (_newSessionTime == null) {
      Get.snackbar('Perhatian', 'Lengkapi tanggal & jam baru dulu');
      return;
    }

    final result = ctrl.submitReschedule(
      bookingId: booking.id,
      originalSessionTime: booking.sessionTime,
      newSessionTime: _newSessionTime!,
      reason: _reasonCtrl.text,
      switchTutor: _switchTutor,
    );
    if (result == null) return; // errorMessage sudah di-set controller

    _showResultDialog(context, result);
  }

  void _showResultDialog(BuildContext context, RescheduleModel result) {
    final approved = result.status == RescheduleStatus.disetujui;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          approved ? 'Reschedule Disetujui' : 'Menunggu Approval Admin',
        ),
        content: Text(
          approved
              ? 'Jadwal baru: ${AppDateUtils.formatDateTime(result.newSessionTime)}'
              : result.adminNote ?? 'Butuh persetujuan Admin terlebih dahulu.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: AppTextStyles.bodySemiBold.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _dateTimeDisplay(String text, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.textLight, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: text.startsWith('Pilih')
                ? AppColors.textLight
                : AppColors.textPrimary,
          ),
        ),
      ],
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
