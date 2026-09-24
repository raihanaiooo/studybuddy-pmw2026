import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'supabase_service.dart';
import '../constants/supabase_constants.dart';

/// Service untuk FCM push notification
class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  /// Setup FCM dan local notification saat app init
  static Future<void> initialize() async {
    // Request permission iOS
    await _messaging.requestPermission();

    // Konfigurasi local notification (untuk foreground)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Handler notif saat app di foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Simpan FCM token ke Supabase
    await _saveFcmToken();
  }

  /// Simpan token FCM user ke database untuk server-side push
  static Future<void> _saveFcmToken() async {
    final token = await _messaging.getToken();
    final userId = SupabaseService.auth.currentUser?.id;
    if (token == null || userId == null) return;

    await SupabaseService.client
        .from(SupabaseConstants.tableUsers)
        .update({'fcm_token': token})
        .eq('id', userId);
  }

  /// Tampilkan notif lokal saat app aktif di foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _localNotif.show(
      message.hashCode,
      message.notification?.title ?? 'Study Buddy',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'studybuddy_channel',
          'Study Buddy',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
