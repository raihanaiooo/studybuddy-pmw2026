import 'package:intl/intl.dart';

/// Utility fungsi untuk format dan validasi tanggal/waktu
class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id');
  static final _timeFormat = DateFormat('HH:mm');
  static final _datetimeFormat = DateFormat('dd MMM yyyy • HH:mm', 'id');

  /// Format tanggal: "15 Maret 2026"
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// Format jam: "09:00"
  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  /// Format lengkap: "15 Maret 2026 • 09:00"
  static String formatDateTime(DateTime dt) => _datetimeFormat.format(dt);

  /// Validasi booking minimum H-5 jam dari sekarang
  static bool isBookingTimeValid(DateTime sessionTime) {
    final minTime = DateTime.now().add(const Duration(hours: 5));
    return sessionTime.isAfter(minTime);
  }

  /// Sisa waktu dalam format readable: "2j 30m"
  static String remainingTime(DateTime targetTime) {
    final diff = targetTime.difference(DateTime.now());
    if (diff.isNegative) return 'Sudah lewat';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '${hours}j ${minutes}m';
    return '${minutes}m';
  }
}
