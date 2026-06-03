import 'package:get/get.dart';
import '../../shared/constants/prototype.dart';
import '../../core/services/mock_service.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/constants/supabase_constants.dart';
import '../../models/booking_model.dart';
import 'tutor_dashboard_controller.dart';
import '../../mock/mock_data.dart';
import '../../core/services/mock_service.dart';

/// Status slot jam mengajar
enum SlotStatus { available, booked, inactive }

class TimeSlot {
  final String time; // "08.00"
  final SlotStatus status;

  const TimeSlot({required this.time, required this.status});

  TimeSlot copyWith({SlotStatus? status}) =>
      TimeSlot(time: time, status: status ?? this.status);
}

class TutorScheduleController extends GetxController {
  final _dashboard = Get.find<TutorDashboardController>();

  final RxBool isOnline = true.obs;
  final RxInt selectedDayIndex = 0.obs;
  final RxList<TimeSlot> timeSlots = <TimeSlot>[].obs;
  final RxList<BookingModel> todayBookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;

  // Hari aktif minggu ini (Sen - Min)
  final List<_DayItem> weekDays = [];

  static const List<String> _allSlots = [
    '08.00',
    '09.00',
    '10.00',
    '11.00',
    '12.00',
    '13.00',
    '14.00',
    '15.00',
    '16.00',
    '17.00',
    '18.00',
    '19.00',
    '20.00',
    '21.00',
  ];

  // Slot yang tutor aktifkan (bisa disimpan ke DB)
  final RxSet<String> activatedSlots = <String>{
    '08.00',
    '09.00',
    '13.00',
    '14.00',
    '19.00',
    '20.00',
  }.obs;

  @override
  void onInit() {
    super.onInit();
    isOnline.value = _dashboard.isOnline.value;
    _buildWeekDays();
    loadSchedule();
  }

  void _buildWeekDays() {
    final now = DateTime.now();
    // Senin minggu ini
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      weekDays.add(_DayItem(label: labels[i], date: day.day, dateTime: day));
    }
  }

  Future<void> loadSchedule() async {
    isLoading.value = true;
    try {
      await _buildTimeSlots();
      await _fetchTodayBookings();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _buildTimeSlots() async {
    final tutorId = _dashboard.tutorProfile.value?.id;
    Set<String> bookedSlots = {};

    if (tutorId != null && !kUseMock) {
      final selectedDate = weekDays[selectedDayIndex.value].dateTime;
      final data = await SupabaseService.client
          .from(SupabaseConstants.tableBookings)
          .select('start_time')
          .eq('tutor_id', tutorId)
          .eq('session_date', selectedDate.toIso8601String().split('T')[0])
          .inFilter('status', ['pending', 'confirmed']);

      bookedSlots = (data as List)
          .map((e) => _formatTime(e['start_time'] as String))
          .toSet();
    } else if (kUseMock) {
      // Mock: beberapa slot dianggap terbooking
      bookedSlots = {'09.00', '14.00'};
    }

    // Tampilkan hanya subset slot (sesuai desain: 9 slot)
    const displaySlots = [
      '08.00',
      '09.00',
      '10.00',
      '13.00',
      '14.00',
      '15.00',
      '19.00',
      '20.00',
      '21.00',
    ];

    timeSlots.value = displaySlots.map((t) {
      if (bookedSlots.contains(t))
        return TimeSlot(time: t, status: SlotStatus.booked);
      if (activatedSlots.contains(t))
        return TimeSlot(time: t, status: SlotStatus.available);
      return TimeSlot(time: t, status: SlotStatus.inactive);
    }).toList();
  }

  Future<void> _fetchTodayBookings() async {
    final tutorId = _dashboard.tutorProfile.value?.id;
    if (tutorId == null) return;

    if (kUseMock) {
      final all = await MockService.fetchBookingsForTutor(tutorId);
      todayBookings.value = all
          .where((b) => b.status == 'pending' || b.status == 'confirmed')
          .take(3)
          .toList();
      return;
    }

    final today = DateTime.now();
    final data = await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .select('*, users!customer_id(full_name)')
        .eq('tutor_id', tutorId)
        .eq('session_date', today.toIso8601String().split('T')[0])
        .inFilter('status', ['pending', 'confirmed']);

    todayBookings.value = (data as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  void selectDay(int index) {
    selectedDayIndex.value = index;
    loadSchedule();
  }

  void toggleSlot(String time) {
    // Tidak bisa toggle slot yang sudah dipesan
    final slot = timeSlots.firstWhereOrNull((s) => s.time == time);
    if (slot == null || slot.status == SlotStatus.booked) return;

    if (activatedSlots.contains(time)) {
      activatedSlots.remove(time);
    } else {
      activatedSlots.add(time);
    }
    _buildTimeSlots();
    // TODO: simpan ke Supabase (tutor_availability table)
  }

  Future<void> toggleOnlineStatus(bool value) async {
    isOnline.value = value;
    await _dashboard.toggleOnlineStatus(value);
  }

  String _formatTime(String rawTime) {
    // "08:00:00" → "08.00"
    return rawTime.substring(0, 5).replaceAll(':', '.');
  }

  int get pendingConfirmCount =>
      todayBookings.where((b) => b.status == 'pending').length;
}

class _DayItem {
  final String label;
  final int date;
  final DateTime dateTime;
  const _DayItem({
    required this.label,
    required this.date,
    required this.dateTime,
  });
}
