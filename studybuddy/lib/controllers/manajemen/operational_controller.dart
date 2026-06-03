import 'package:get/get.dart';
import '../../models/booking_model.dart';
import '../../mock/mock_data.dart';

class OperationalController extends GetxController {
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxString filterStatus = ''.obs; // empty = all

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  void loadBookings() {
    bookings.value = mockBookings.map((m) => BookingModel.fromMap(m)).toList();
  }

  void approveBooking(String id) {
    final idx = mockBookings.indexWhere((b) => b['id'] == id);
    if (idx != -1) {
      mockBookings[idx]['status'] = 'confirmed';
      loadBookings();
    }
  }

  void cancelBooking(String id) {
    final idx = mockBookings.indexWhere((b) => b['id'] == id);
    if (idx != -1) {
      mockBookings[idx]['status'] = 'cancelled';
      loadBookings();
    }
  }

  List<BookingModel> get filtered {
    if (filterStatus.value.isEmpty) return bookings;
    return bookings.where((b) => b.status == filterStatus.value).toList();
  }
}
