import '../../models/tutor_model.dart';
import '../../models/booking_model.dart';
import '../../models/review_model.dart';
import '../../mock/mock_data.dart';

class MockService {
  static Future<List<TutorModel>> fetchTutors() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return mockTutors;
  }

  static Future<List<ReviewModel>> fetchReviews(String tutorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      ReviewModel(
        id: 'r1',
        sessionId: 's1',
        customerId: 'c1',
        tutorId: tutorId,
        rating: 5,
        comment: 'Sesi sangat membantu, clear dan sabar.',
        subject: 'Kalkulus',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  static Future<List<BookingModel>> fetchBookingsForTutor(
    String tutorId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockBookings
        .where((b) => b['tutor_id'] == tutorId)
        .map((b) => BookingModel.fromMap(b))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> fetchBookingsForUser(
    String userId, {
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (role == 'tutor') {
      return mockBookings.where((b) => b['tutor_id'] == userId).toList();
    }
    return mockBookings.where((b) => b['customer_id'] == userId).toList();
  }

  static Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> booking,
  ) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final id = 'b${mockBookings.length + 1}';
    final record = {
      ...booking,
      'id': id,
      'created_at': DateTime.now().toIso8601String(),
      'status': booking['status'] ?? 'confirmed',
    };
    mockBookings.add(record);
    return record;
  }

  static Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = mockBookings.indexWhere((b) => b['id'] == bookingId);
    if (idx != -1) mockBookings[idx]['status'] = 'cancelled';
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> startSession(
    Map<String, dynamic> sessionData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = 's${mockSessions.length + 1}';
    final record = {
      ...sessionData,
      'id': id,
      'start_time': DateTime.now().toIso8601String(),
      'status': 'active',
    };
    mockSessions.add(record);
    return record;
  }

  static Future<void> endSession(String sessionId, int elapsedSeconds) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = mockSessions.indexWhere((s) => s['id'] == sessionId);
    if (idx != -1) {
      mockSessions[idx]['end_time'] = DateTime.now().toIso8601String();
      mockSessions[idx]['status'] = 'ended';
      mockSessions[idx]['elapsed_seconds'] = elapsedSeconds;
    }
  }

  static Future<Map<String, dynamic>?> getSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = mockSessions.indexWhere((s) => s['id'] == sessionId);
    if (idx == -1) return null;
    return mockSessions[idx];
  }
}
