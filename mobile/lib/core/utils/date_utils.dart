import 'package:intl/intl.dart';
import '../../domain/slot_booking_policy.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id');
  static final _timeFormat = DateFormat('HH:mm');
  static final _datetimeFormat = DateFormat('dd MMM yyyy • HH:mm', 'id');

  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDateTime(DateTime dt) => _datetimeFormat.format(dt);

  /// Delegate ke SlotBookingPolicy (single source of truth)
  static bool isBookingTimeValid(DateTime sessionTime) =>
      SlotBookingPolicy.isBookingTimeValid(sessionTime);

  static String remainingTime(DateTime targetTime) {
    final diff = targetTime.difference(DateTime.now());
    if (diff.isNegative) return 'Sudah lewat';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '${hours}j ${minutes}m';
    return '${minutes}m';
  }
}
