import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../models/tutor_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Screen booking: pilih tanggal, waktu, durasi, dan tipe sesi
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _subjectCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _duration = 60;
  String _sessionType = 'video';

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime? get _sessionDateTime {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingController>();
    final tutor = Get.arguments as TutorModel?;

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
            // Tutor info card
            if (tutor != null)
              Container(
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
              ),

            // Info H-5 jam
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Booking minimal 5 jam sebelum sesi dimulai',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Mata kuliah
            _sectionTitle('Mata Kuliah'),
            TextField(
              controller: _subjectCtrl,
              decoration: _inputDeco('Contoh: Kalkulus II, Fisika Dasar'),
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
            const SizedBox(height: 16),

            // Tanggal
            _sectionTitle('Tanggal'),
            GestureDetector(
              onTap: _pickDate,
              child: _dateTimeDisplay(
                _selectedDate != null
                    ? DateFormat(
                        'EEEE, dd MMM yyyy',
                        'id',
                      ).format(_selectedDate!)
                    : 'Pilih tanggal',
                Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Jam
            _sectionTitle('Jam Mulai'),
            GestureDetector(
              onTap: _pickTime,
              child: _dateTimeDisplay(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Pilih jam',
                Icons.access_time_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Durasi
            _sectionTitle('Durasi'),
            Wrap(
              spacing: 8,
              children: [60, 90, 120]
                  .map(
                    (d) => ChoiceChip(
                      label: Text(
                        '${d ~/ 60} jam${d % 60 != 0 ? ' ${d % 60}m' : ''}',
                      ),
                      selected: _duration == d,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: _duration == d
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) => setState(() => _duration = d),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

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
                  onPressed: ctrl.isLoading.value || tutor == null
                      ? null
                      : () {
                          if (_sessionDateTime == null ||
                              _subjectCtrl.text.isEmpty) {
                            Get.snackbar(
                              'Perhatian',
                              'Lengkapi tanggal, jam, dan mata kuliah',
                            );
                            return;
                          }
                          ctrl.createBooking(
                            tutorId: tutor.id,
                            sessionTime: _sessionDateTime!,
                            durationMinutes: _duration,
                            subject: _subjectCtrl.text,
                            sessionType: _sessionType,
                            notes: _notesCtrl.text.isNotEmpty
                                ? _notesCtrl.text
                                : null,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
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
