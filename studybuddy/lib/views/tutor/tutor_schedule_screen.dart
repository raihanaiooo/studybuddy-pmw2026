import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/tutor/tutor_schedule_controller.dart';
import '../../shared/widgets/app_bottom_nav.dart';

import '../../../app/routes.dart';

class TutorScheduleScreen extends StatelessWidget {
  const TutorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TutorScheduleController c = Get.put(
      TutorScheduleController(),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(c),
                    _buildWarningCard(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      child: Column(
                        children: [
                          _buildWeekSection(c),
                          const SizedBox(height: 18),
                          _buildSlotsSection(c),
                          const SizedBox(height: 18),
                          _buildTodayBookingSection(c),
                          const SizedBox(height: 18),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TutorScheduleController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F6B57), Color(0xFF1DBF83), Color(0xFF46D7A2)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -55,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _miniButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Get.back(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Kelola Jadwal Tutor',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  _miniButton(icon: Icons.sync_rounded, onTap: c.loadSchedule),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Status: ${c.isOnline.value ? "Online" : "Offline"}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customer bisa booking slot aktif',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => GestureDetector(
                        onTap: () => c.toggleOnlineStatus(!c.isOnline.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 46,
                          height: 25,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: c.isOnline.value
                                ? const Color(0xFFDDF8EE)
                                : Colors.white24,
                          ),
                          child: Align(
                            alignment: c.isOnline.value
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 19,
                              height: 19,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.isOnline.value
                                    ? const Color(0xFF1DBF83)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: Colors.white.withOpacity(0.16),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD8AD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Color(0xFF9A5300),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Aturan Booking MVP',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF9A5300),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Slot hanya bisa dipesan minimal H-5 jam sebelum sesi dimulai. Slot yang terlalu dekat otomatis disembunyikan dari customer.',
            style: TextStyle(
              color: Color(0xFFB06A13),
              fontSize: 10,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSection(TutorScheduleController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.calendar_month_outlined,
          title: 'Pilih Hari Aktif Mingguan',
        ),
        const SizedBox(height: 10),
        GetBuilder<TutorScheduleController>(
          builder: (_) => GridView.builder(
            shrinkWrap: true,
            itemCount: c.weekDays.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: .82,
            ),
            itemBuilder: (_, i) {
              final day = c.weekDays[i];
              final active = c.selectedDayIndex.value == i;
              final isSunday = day.label == 'Min';

              return GestureDetector(
                onTap: isSunday ? null : () => c.selectDay(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFE8FFF6) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active
                          ? const Color(0xFF9CE3C8)
                          : const Color(0xFFDCE5F2),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5F6F85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSunday ? '-' : '${day.date}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10233F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsSection(TutorScheduleController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.access_time_rounded,
          title: 'Slot Jam Mengajar',
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE5F2)),
          ),
          child: Column(
            children: [
              GetBuilder<TutorScheduleController>(
                builder: (_) => GridView.builder(
                  shrinkWrap: true,
                  itemCount: c.timeSlots.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (_, i) {
                    final slot = c.timeSlots[i];
                    return GestureDetector(
                      onTap: slot.status == SlotStatus.booked
                          ? null
                          : () => c.toggleSlot(slot.time),
                      child: _slotItem(slot),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _legend(const Color(0xFF1DBF83), 'Tersedia'),
                  _legend(const Color(0xFFCEDDFF), 'Booked'),
                  _legend(const Color(0xFFDfe4eb), 'Nonaktif'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _slotItem(TimeSlot slot) {
    Color bg;
    Color border;
    Color text;
    TextDecoration? decoration;

    switch (slot.status) {
      case SlotStatus.available:
        bg = const Color(0xFF1DBF83);
        border = const Color(0xFF1DBF83);
        text = Colors.white;
        break;
      case SlotStatus.booked:
        bg = const Color(0xFFEDF3FF);
        border = const Color(0xFFC8DAFB);
        text = const Color(0xFF24539F);
        break;
      case SlotStatus.inactive:
        bg = const Color(0xFFF3F4F6);
        border = const Color(0xFFE5E7EB);
        text = const Color(0xFF98A1AE);
        decoration = TextDecoration.lineThrough;
        break;
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border, width: 1.4),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          slot.time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: text,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            decoration: decoration,
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5F6F85),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayBookingSection(TutorScheduleController c) {
    return GetBuilder<TutorScheduleController>(
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Booking Hari Ini',
            rightText: '${c.pendingConfirmCount} pending',
          ),
          const SizedBox(height: 10),
          if (c.todayBookings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE5F2)),
              ),
              child: const Text(
                'Belum ada booking hari ini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6F85),
                ),
              ),
            )
          else
            Column(
              children: c.todayBookings.map((b) => _bookingItem(b)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _bookingItem(dynamic booking) {
    final isPending = booking.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5F2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.customerName ?? "Customer"} - ${booking.subject}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10233F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.startTime.substring(0, 5)} - ${booking.endTime.substring(0, 5)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF5F6F85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isPending
                  ? const Color(0xFFFFF1DC)
                  : const Color(0xFFDDF8EE),
            ),
            child: Text(
              isPending ? 'Menunggu' : 'Confirmed',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isPending
                    ? const Color(0xFFAD6A11)
                    : const Color(0xFF0F7F57),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE5F2), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Atur GMeet',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5F6F85),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F6B57), Color(0xFF1DBF83)],
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Simpan Jadwal',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    String? rightText,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F0FF),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 12, color: const Color(0xFF295DB7)),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10233F),
            ),
          ),
        ),
        if (rightText != null)
          Text(
            rightText,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5F6F85),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return AppBottomNav(
      currentIndex: 1,
      items: const [
        BottomNavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
        BottomNavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
        BottomNavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
        BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
      ],
      onTap: (i) {
        switch (i) {
          case 0:
            Get.offAllNamed(AppRoutes.tutorDashboard);
            break;
          case 1:
            break; // already here
          case 2:
            Get.snackbar('Info', 'Fitur chat untuk tutor segera hadir',
                snackPosition: SnackPosition.BOTTOM);
            break;
          case 3:
            Get.toNamed(AppRoutes.tutorProfile);
            break;
        }
      },
    );
  }
}
