import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:studybuddy/controllers/auth_controller.dart';
import 'package:studybuddy/controllers/profile_controller.dart';
import 'package:studybuddy/models/user_model.dart';
import 'package:studybuddy/views/customer/profile_screen.dart';
import 'package:studybuddy/views/tutor/tutor_profile_screen.dart';

/// AuthController.onInit() memicu fetch ke Supabase (gagal di widget test
/// karena belum diinisialisasi, lalu ditangkap & di-set null oleh
/// try/catch di controller). Tunggu satu pump supaya fetch gagal itu
/// selesai dulu sebelum kita seed data dummy, biar tidak balapan.
Future<AuthController> _seedAuth(WidgetTester tester, UserModel user) async {
  final auth = Get.put(AuthController());
  await tester.pump();
  auth.currentUser.value = user;
  return auth;
}

final _dummyBuddy = UserModel(
  id: 'me',
  email: 'buddy@studybuddy.test',
  fullName: 'Sari Amalia',
  role: 'customer',
  createdAt: DateTime(2026, 1, 1),
  age: 19,
  gradeLevel: 'Mahasiswa (S1)',
  school: 'Politeknik Negeri Bandung',
  interestedSubjects: const ['Kalkulus', 'Basis Data'],
);

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(ProfileController());
  });

  tearDown(Get.reset);

  testWidgets('CustomerProfileScreen menampilkan data diri Buddy', (
    tester,
  ) async {
    await _seedAuth(tester, _dummyBuddy);
    await tester.pumpWidget(const GetMaterialApp(home: CustomerProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sari Amalia'), findsOneWidget);
    expect(find.text('Politeknik Negeri Bandung'), findsOneWidget);
    expect(find.text('Kalkulus, Basis Data'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
  });

  testWidgets('Edit Profil membuka form dan menyimpan perubahan nama', (
    tester,
  ) async {
    final auth = await _seedAuth(tester, _dummyBuddy);
    await tester.pumpWidget(const GetMaterialApp(home: CustomerProfileScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Edit Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Sari A. Putri');
    await tester.tap(find.text('Simpan'));
    // Cek efek langsung ke state, tanpa bergantung timing animasi
    // tutup-modal + Get.snackbar (keduanya butuh beberapa frame settle).
    await tester.pump();

    expect(auth.currentUser.value!.fullName, 'Sari A. Putri');
  });

  testWidgets('TutorProfileScreen menampilkan bio, mapel, & dokumen', (
    tester,
  ) async {
    await _seedAuth(tester, _dummyBuddy);
    await tester.pumpWidget(const GetMaterialApp(home: TutorProfileScreen()));
    await tester.pumpAndSettle();

    // Muncul di header tutor + di baris dokumen yang sudah terverifikasi.
    expect(find.text('Terverifikasi'), findsWidgets);
    expect(find.text('⭐ Tutor of the Month'), findsOneWidget);
    expect(find.text('Kalkulus'), findsOneWidget);
    expect(find.text('Transkrip Nilai'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('CV / Portfolio'), 300);
    await tester.pumpAndSettle();
    expect(find.text('CV / Portfolio'), findsOneWidget);
  });
}
