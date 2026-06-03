import 'package:get/get.dart';
import '../../shared/constants/prototype.dart';
import '../../core/services/mock_service.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/constants/supabase_constants.dart';
import '../../models/booking_model.dart';
import '../../models/tutor_model.dart';
import '../auth_controller.dart';

class TutorDashboardController extends GetxController {
  final _auth = Get.find<AuthController>();

  final Rx<TutorModel?> tutorProfile = Rx<TutorModel?>(null);
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxList<BookingModel> filteredBookings = <BookingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isOnline = true.obs;
  final RxString activeFilter = 'all'.obs;

  // Stats
  final RxInt bookingMasuk = 0.obs;
  final RxInt sesiHariIni = 0.obs;
  final RxDouble ratingRataRata = 0.0.obs;
  final RxDouble pendapatanBulanIni = 0.0.obs;
  final RxDouble pendapatanGrowth = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchTutorProfile(), _fetchBookings()]);
      _calculateStats();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchTutorProfile() async {
    final userId = _auth.currentUser.value?.id;
    if (userId == null) return;

    if (kUseMock) {
      final tutors = await MockService.fetchTutors();
      tutorProfile.value = tutors.isNotEmpty ? tutors.first : null;
      isOnline.value = tutorProfile.value?.isOnline ?? true;
      return;
    }

    final data = await SupabaseService.client
        .from(SupabaseConstants.tableTutors)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data != null) {
      tutorProfile.value = TutorModel.fromMap(data);
      isOnline.value = tutorProfile.value?.isOnline ?? true;
    }
  }

  Future<void> _fetchBookings() async {
    final tutorId = tutorProfile.value?.id;
    if (tutorId == null) return;

    if (kUseMock) {
      bookings.value = await MockService.fetchBookingsForTutor(tutorId);
      _applyFilter();
      return;
    }

    final data = await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .select('*, users!customer_id(full_name, avatar_url)')
        .eq('tutor_id', tutorId)
        .inFilter('status', ['pending', 'confirmed'])
        .order('session_date', ascending: true);

    bookings.value = (data as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
    _applyFilter();
  }

  void _calculateStats() {
    final today = DateTime.now();
    bookingMasuk.value = bookings.where((b) => b.status == 'pending').length;
    sesiHariIni.value = bookings.where((b) {
      return b.status == 'confirmed' &&
          b.sessionDate.year == today.year &&
          b.sessionDate.month == today.month &&
          b.sessionDate.day == today.day;
    }).length;
    ratingRataRata.value = tutorProfile.value?.rating ?? 0.0;
    // Mock pendapatan
    pendapatanBulanIni.value = 1250000;
    pendapatanGrowth.value = 18;
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    switch (activeFilter.value) {
      case 'pending':
        filteredBookings.value = bookings
            .where((b) => b.status == 'pending')
            .toList();
        break;
      case 'confirmed':
        filteredBookings.value = bookings
            .where((b) => b.status == 'confirmed')
            .toList();
        break;
      default:
        filteredBookings.value = bookings;
    }
  }

  Future<void> toggleOnlineStatus(bool value) async {
    isOnline.value = value;
    final tutorId = tutorProfile.value?.id;
    if (tutorId == null || kUseMock) return;

    await SupabaseService.client
        .from(SupabaseConstants.tableTutors)
        .update({'is_online': value})
        .eq('id', tutorId);
  }

  Future<void> confirmBooking(String bookingId) async {
    if (kUseMock) {
      final idx = bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        bookings[idx] = bookings[idx].copyWith(status: 'confirmed');
        _calculateStats();
        _applyFilter();
      }
      return;
    }

    await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .update({'status': 'confirmed'})
        .eq('id', bookingId);

    await _fetchBookings();
    _calculateStats();
  }

  Future<void> rejectBooking(String bookingId) async {
    if (kUseMock) {
      final idx = bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        bookings[idx] = bookings[idx].copyWith(status: 'cancelled');
        _calculateStats();
        _applyFilter();
      }
      return;
    }

    await SupabaseService.client
        .from(SupabaseConstants.tableBookings)
        .update({'status': 'cancelled'})
        .eq('id', bookingId);

    await _fetchBookings();
    _calculateStats();
  }

  int get pendingCount => bookings.where((b) => b.status == 'pending').length;
  int get confirmedCount =>
      bookings.where((b) => b.status == 'confirmed').length;
}
