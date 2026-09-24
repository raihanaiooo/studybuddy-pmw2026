import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Wajib sebelum AppDateUtils dipakai — DateFormat(..., 'id') akan
  // throw LocaleDataException tanpa ini.
  await initializeDateFormatting('id', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseService.initialize();
  // await NotificationService.initialize();
  runApp(const StudyBuddyApp());
}
