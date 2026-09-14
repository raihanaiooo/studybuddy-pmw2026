import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/tutor_model.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../app/routes.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _subjectCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _selectedDayIndex = 1;
  String _selectedTime = '13.00';
  String _sessionType = 'video';
  String _package = 'Intensif';

  final List<Map<String, String>> _weekDays = [
    {'day': 'Sen', 'date': '17'},
    {'day': 'Sel', 'date': '18'},
    {'day': 'Rab', 'date': '19'},
    {'day': 'Kam', 'date': '20'},
    {'day': 'Jum', 'date': '21'},
    {'day': 'Sab', 'date': '22'},
  ];

  final List<Map<String, dynamic>> _timeSlots = [
    {'time': '08.00', 'available': false},
    {'time': '09.00', 'available': false},
    {'time': '10.00', 'available': true},
    {'time': '11.00', 'available': true},
    {'time': '13.00', 'available': true},
    {'time': '14.00', 'available': true},
    {'time': '15.00', 'available': true},
    {'time': '16.00', 'available': false},
    {'time': '19.00', 'available': true},
    {'time': '20.00', 'available': true},
    {'time': '21.00', 'available': true},
    {'time': '22.00', 'available': false},
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutor = Get.arguments as TutorModel?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 8, 16, 12),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 18, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Booking Sesi',
                    style: AppTextStyles.heading3),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tutor Mini Profile
                  if (tutor != null) _buildTutorMiniProfile(tutor),
                  const SizedBox(height: 20),

                  // Pilih Paket
                  _buildSectionTitle('Pilih Paket Sesi'),
                  const SizedBox(height: 10),
                  _buildPackageGrid(),
                  const SizedBox(height: 20),

                  // Pilih Tanggal
                  _buildSectionTitle('Pilih Tanggal'),
                  const SizedBox(height: 10),
                  _buildDateRow(),
                  const SizedBox(height: 20),

                  // Pilih Jam
                  _buildSectionTitle('Pilih Waktu'),
                  const SizedBox(height: 4),
                  _buildH5Info(),
                  const SizedBox(height: 10),
                  _buildTimeGrid(),
                  const SizedBox(height: 20),

                  // Mode Sesi
                  _buildSectionTitle('Mode Sesi'),
                  const SizedBox(height: 10),
                  _buildModeSelector(),
                  const SizedBox(height: 20),

                  // Ringkasan
                  _buildOrderSummary(tutor),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Book Button
          _buildBookButton(tutor),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        onTap: (i) {
          switch (i) {
            case 0:
              Get.offAllNamed(AppRoutes.customerDashboard);
              break;
            case 1:
              Get.toNamed(AppRoutes.tutorList);
              break;
            case 2:
              Get.toNamed(AppRoutes.chatList);
              break;
            case 3:
              Get.toNamed(AppRoutes.customerSchedule);
              break;
            case 4:
              Get.toNamed(AppRoutes.customerProfile);
              break;
          }
        },
        items: const [
          BottomNavItem(icon: Icons.home_rounded, label: 'Beranda'),
          BottomNavItem(icon: Icons.search_rounded, label: 'Cari'),
          BottomNavItem(icon: Icons.chat_bubble_rounded, label: 'Chat'),
          BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Jadwal'),
          BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildTutorMiniProfile(TutorModel tutor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.blueLight]),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              tutor.fullName[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tutor.fullName, style: AppTextStyles.heading3),
                const SizedBox(height: 2),
                Text(
                  '${tutor.subjects.take(2).join(' & ')} · ${tutor.university}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                        5,
                        (i) => Icon(Icons.star_rounded,
                            size: 14,
                            color: i < tutor.rating.round()
                                ? AppColors.primaryYellow
                                : AppColors.border)),
                    const SizedBox(width: 4),
                    Text('${tutor.rating}',
                        style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 12, color: AppColors.textPrimary)),
                    const SizedBox(width: 4),
                    Text('(${tutor.totalReviews} ulasan)',
                        style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.heading3.copyWith(fontFamily: 'Poppins'));
  }

  Widget _buildPackageGrid() {
    final packages = [
      {'name': 'Singkat', 'desc': '1 × 60 menit', 'price': 'Rp50.000'},
      {'name': 'Intensif', 'desc': '3 × 60 menit', 'price': 'Rp135.000'},
      {'name': 'Reguler', 'desc': '1 × 90 menit', 'price': 'Rp70.000'},
      {'name': 'Maraton', 'desc': '5 × 60 menit', 'price': 'Rp210.000'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: packages.length,
      itemBuilder: (_, i) {
        final p = packages[i];
        final selected = _package == p['name'];
        final isPopular = p['name'] == 'Intensif';
        return GestureDetector(
          onTap: () => setState(() => _package = p['name']!),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue.withAlpha((0.06 * 255).round())
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        selected ? AppColors.primaryBlue : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p['name']!,
                        style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 13,
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(p['desc']!,
                        style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(p['price']!,
                        style: AppTextStyles.heading3.copyWith(
                            fontSize: 14,
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary)),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 12, color: Colors.white),
                  ),
                ),
              if (isPopular)
                Positioned(
                  top: -4,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('POPULER',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRow() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (_, i) {
          final d = _weekDays[i];
          final selected = _selectedDayIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = i),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d['day']!,
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: selected
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(d['date']!,
                      style: AppTextStyles.heading3.copyWith(
                          fontSize: 16,
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildH5Info() {
    return Text(
      '⚡ Minimal booking H-5 jam sebelum sesi',
      style: AppTextStyles.caption.copyWith(
          fontSize: 10, color: AppColors.textSecondary),
    );
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (_, i) {
        final slot = _timeSlots[i];
        final time = slot['time'] as String;
        final available = slot['available'] as bool;
        final selected = _selectedTime == time;

        return GestureDetector(
          onTap: available
              ? () => setState(() => _selectedTime = time)
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryBlue
                  : available
                      ? Colors.white
                      : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primaryBlue
                    : available
                        ? AppColors.border
                        : AppColors.border,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              time,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontSize: 12,
                color: selected
                    ? Colors.white
                    : available
                        ? AppColors.textPrimary
                        : AppColors.textLight,
                decoration: !available ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        _modeCard('video', '🎥', 'Video Call', 'Via Google Meet'),
        const SizedBox(width: 10),
        _modeCard('chat', '💬', 'Chat', 'Dengan timer sesi'),
      ],
    );
  }

  Widget _modeCard(
      String type, String icon, String name, String desc) {
    final selected = _sessionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sessionType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withAlpha((0.06 * 255).round())
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(name,
                  style: AppTextStyles.bodySemiBold.copyWith(
                      fontSize: 13,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(desc,
                  style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(TutorModel? tutor) {
    final price = tutor != null
        ? 'Rp${_calcTotalPrice(tutor).toStringAsFixed(0)}'
        : '-';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha((0.06 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Pemesanan',
              style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _summaryRow('Paket', '$_package (${_packageDesc()})'),
          const SizedBox(height: 6),
          _summaryRow('Tanggal',
              '${_weekDays[_selectedDayIndex]['day']}, ${_weekDays[_selectedDayIndex]['date']} Mar 2026'),
          const SizedBox(height: 6),
          _summaryRow('Waktu', '$_selectedTime WIB'),
          const SizedBox(height: 6),
          _summaryRow('Mode',
              _sessionType == 'video' ? '🎥 Google Meet' : '💬 Chat'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: AppTextStyles.heading3),
              Text(price,
                  style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryBlue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value,
            style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13)),
      ],
    );
  }

  String _packageDesc() {
    switch (_package) {
      case 'Singkat':
        return '1×60 mnt';
      case 'Intensif':
        return '3×60 mnt';
      case 'Reguler':
        return '1×90 mnt';
      case 'Maraton':
        return '5×60 mnt';
      default:
        return '';
    }
  }

  double _calcTotalPrice(TutorModel tutor) {
    double base = tutor.pricePerHour;
    switch (_package) {
      case 'Singkat':
        return base * 1;
      case 'Intensif':
        return base * 3 * 0.9;
      case 'Reguler':
        return base * 1.5;
      case 'Maraton':
        return base * 5 * 0.85;
      default:
        return base;
    }
  }

  Widget _buildBookButton(TutorModel? tutor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: tutor != null
              ? () => _showBookingSummary(context, tutor)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            '📅 Pesan Sekarang',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }

  void _showBookingSummary(BuildContext context, TutorModel tutor) {
    final price = _calcTotalPrice(tutor);
    final fmt =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text('Ringkasan Booking',
                  style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              _summaryRow('Tutor', tutor.fullName),
              _summaryRow('Paket', '$_package (${_packageDesc()})'),
              _summaryRow('Tanggal',
                  '${_weekDays[_selectedDayIndex]['day']}, ${_weekDays[_selectedDayIndex]['date']} Mar 2026'),
              _summaryRow('Waktu', '$_selectedTime WIB'),
              _summaryRow('Mode',
                  _sessionType == 'video' ? 'Google Meet' : 'Chat'),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: AppTextStyles.heading3),
                  Text(fmt.format(price),
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.primaryBlue)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar('Berhasil',
                            'Booking berhasil dibuat (prototype)');
                        Get.offNamed(AppRoutes.customerSchedule);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Konfirmasi Booking',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
