import '../models/reschedule_model.dart';

abstract class RescheduleRepository {
  Future<List<RescheduleModel>> fetchMyRequests(String userId);
  Future<RescheduleModel> submitRequest({
    required String bookingId,
    required String requestedBy,
    required String requestedByRole,
    required String reason,
    required DateTime originalSessionTime,
    required DateTime newSessionTime,
  });
  Future<int> countMyRequestsThisMonth(String userId);
}
