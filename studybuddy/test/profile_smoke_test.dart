import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studybuddy/controllers/auth_controller.dart';
import 'package:studybuddy/controllers/profile_controller.dart';
import 'package:studybuddy/domain/profile_repository.dart';
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
  phone: '081234567890',
  age: 19,
  gradeLevel: 'Mahasiswa (S1)',
  school: 'Politeknik Negeri Bandung',
  interestedSubjects: const ['Kalkulus', 'Basis Data'],
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('CustomerProfileScreen menampilkan data diri Buddy', (
    tester,
  ) async {
    await _seedAuth(tester, _dummyBuddy);
    Get.put(ProfileController());
    await tester.pumpWidget(const GetMaterialApp(home: CustomerProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sari Amalia'), findsOneWidget);
    expect(find.text('Politeknik Negeri Bandung'), findsOneWidget);
    expect(find.text('Kalkulus, Basis Data'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
  });

  testWidgets(
    'Simpan profil Buddy TANPA Supabase: TIDAK ada sukses palsu — state '
    'tidak berubah dan kegagalan kontrak dilaporkan',
    (tester) async {
      final auth = await _seedAuth(tester, _dummyBuddy);
      Get.put(ProfileController());
      await tester.pumpWidget(const GetMaterialApp(home: CustomerProfileScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Edit Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Nama Lengkap'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap'),
        'Sari A. Putri',
      );
      // Tanpa Supabase, repository melempar ProfileBackendMissingException
      // (update ke tabel users tidak bisa diproses) — sheet TIDAK ditutup.
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // State TIDAK berubah — tidak ada lagi snackbar "Berhasil" di atas
      // mutasi memori (C-AUTH-05/D-45).
      expect(auth.currentUser.value!.fullName, 'Sari Amalia');

      final ctrl = Get.find<ProfileController>();
      expect(ctrl.isLoading.value, isFalse);
      // Sheet tetap terbuka agar pengguna bisa mencoba ulang.
      expect(find.text('Simpan'), findsOneWidget);
    },
  );

  testWidgets(
    'TutorProfileScreen menampilkan profil hasil baca repository (bukan dummy)',
    (tester) async {
      // Layar membaca AuthController saat build; onInit-nya gagal senyap
      // di test tanpa Supabase dan tidak dipakai untuk data profil di sini.
      Get.put(AuthController());
      Get.put(
        ProfileController(
          profileRepository: _FakeProfileRepository(
            tutorProfile: const TutorProfileData(
              id: 'tutor-1',
              userId: 'me',
              fullName: 'Arif Rahmat',
              bio: 'Suka ngajar Kalkulus',
              subjects: ['Kalkulus', 'Fisika Dasar'],
              verificationStatus: 'verified',
            ),
            documents: const [
              TutorDocumentRecord(
                id: 'doc-1',
                tutorId: 'tutor-1',
                jenisDokumen: 'transkrip',
                fileUrl: 'https://storage.test/doc-1.pdf',
                status: 'terverifikasi',
              ),
              // Jenis yang TIDAK ada di katalog SRS — label jatuh ke nilai
              // mentah dan klasifikasi dilaporkan jujur, bukan ditebak.
              TutorDocumentRecord(
                id: 'doc-2',
                tutorId: 'tutor-1',
                jenisDokumen: 'skor_utbk',
                status: 'belum_upload',
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(const GetMaterialApp(home: TutorProfileScreen()));

      final ctrl = Get.find<ProfileController>();
      await ctrl.fetchMyTutorProfile(forUserId: 'me');
      await ctrl.fetchTutorDocuments(forUserId: 'me');
      await tester.pumpAndSettle();

      expect(find.text('Arif Rahmat'), findsOneWidget);
      expect(find.text('Suka ngajar Kalkulus'), findsOneWidget);
      expect(find.text('Kalkulus'), findsOneWidget);
      // Muncul di header tutor + di baris dokumen yang sudah terverifikasi.
      expect(find.text('Terverifikasi'), findsWidgets);
      // Dokumen hasil baca backend (bukan katalog enam dokumen lama).
      expect(find.text('Transkrip Nilai'), findsOneWidget);
      // Jenis tak dikenal: label mentah + klasifikasi jujur (D-17/C-DOC-07).
      expect(find.text('skor_utbk'), findsOneWidget);
      expect(find.text('Klasifikasi menunggu konfirmasi'), findsOneWidget);
      // Katalog lama yang konflik SRS tidak lagi dimunculkan controller.
      expect(find.text('CV / Portfolio'), findsNothing);
      expect(find.text('⭐ Tutor of the Month'), findsNothing);
    },
  );

  testWidgets(
    'TutorProfileScreen tanpa data: menampilkan keadaan jujur, bukan profil dummy',
    (tester) async {
      await _seedAuth(tester, _dummyBuddy);
      Get.put(ProfileController());
      await tester.pumpWidget(const GetMaterialApp(home: TutorProfileScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tidak ada lagi profil hardcoded "Aditya Pratama".
      expect(find.text('Aditya Pratama'), findsNothing);
      expect(find.text('Profil belum dimuat. Coba lagi.'), findsOneWidget);
    },
  );

  test(
    'UserModel.copyWith(phone: null) benar-benar mengosongkan field, bukan '
    'jatuh balik ke nilai lama',
    () {
      final updated = _dummyBuddy.copyWith(phone: null);
      expect(updated.phone, isNull);

      // Parameter yang tidak dikirim sama sekali tetap tidak berubah.
      final unchanged = _dummyBuddy.copyWith(fullName: 'Nama Baru');
      expect(unchanged.school, _dummyBuddy.school);
    },
  );
}

/// Repository profil palsu — data disimulasikan TANPA Supabase (belum
/// diinisialisasi di widget test); bentuk data mengikuti kontrak domain.
class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.tutorProfile, this.documents = const []});

  final TutorProfileData? tutorProfile;
  final List<TutorDocumentRecord> documents;

  @override
  Future<BuddyProfileData> fetchBuddyProfile(String userId) async =>
      const BuddyProfileData();

  @override
  Future<void> updateBuddyProfile(String userId, BuddyProfilePatch patch) =>
      throw const ProfileBackendMissingException('test: tanpa Supabase');

  @override
  Future<TutorProfileData> fetchMyTutorProfile(String userId) async {
    final p = tutorProfile;
    if (p == null) {
      throw const ProfileBackendMissingException('test: profil kosong');
    }
    return p;
  }

  @override
  Future<void> updateTutorProfile(String tutorId, TutorProfilePatch patch) =>
      throw const ProfileBackendMissingException('test: tanpa Supabase');

  @override
  Future<List<TutorDocumentRecord>> fetchMyTutorDocuments(String tutorId) async =>
      documents;
}
