import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/profile_repository.dart';

void main() {
  group('BuddyProfilePatch — semantik sentinel (pola UserModel.copyWith)', () {
    test('field yang tidak dikirim tidak dianggap berubah', () {
      final patch = BuddyProfilePatch(fullName: 'Baru');
      expect(patch.hasFullName, isTrue);
      expect(patch.hasPhone, isFalse);
      expect(patch.hasAge, isFalse);
      expect(patch.hasGradeLevel, isFalse);
      expect(patch.hasSchool, isFalse);
      expect(patch.interestedSubjects, isNull);
      expect(patch.isEmpty, isFalse);
    });

    test('mengirim null berarti mengosongkan field secara sengaja', () {
      final patch = BuddyProfilePatch(phone: null);
      expect(patch.hasPhone, isTrue);
      expect(patch.phone, isNull);
      expect(patch.isEmpty, isFalse);
    });

    test('patch kosong terdeteksi — tidak akan menulis apa pun', () {
      expect(BuddyProfilePatch().isEmpty, isTrue);
      // Daftar kosong BUKAN "tidak diubah" — artinya mengosongkan daftar.
      expect(
        BuddyProfilePatch(interestedSubjects: const []).isEmpty,
        isFalse,
      );
    });

    test('patch penuh memetakan semua field', () {
      final patch = BuddyProfilePatch(
        fullName: 'A',
        phone: '081',
        age: 19,
        gradeLevel: 'SMP',
        school: 'SMPN 1',
        interestedSubjects: const ['Fisika'],
      );
      expect(patch.hasFullName, isTrue);
      expect(patch.hasPhone, isTrue);
      expect(patch.hasAge, isTrue);
      expect(patch.hasGradeLevel, isTrue);
      expect(patch.hasSchool, isTrue);
      expect(patch.interestedSubjects, ['Fisika']);
      expect(patch.isEmpty, isFalse);
    });
  });

  group('TutorProfilePatch — semantik kosong', () {
    test('patch kosong terdeteksi', () {
      expect(const TutorProfilePatch().isEmpty, isTrue);
    });

    test('bio kosong string BUKAN patch kosong (artinya mengosongkan bio)', () {
      expect(const TutorProfilePatch(bio: '').isEmpty, isFalse);
      expect(
        const TutorProfilePatch(subjects: []).isEmpty,
        isFalse,
      );
      expect(
        const TutorProfilePatch(extraSkills: []).isEmpty,
        isFalse,
      );
    });
  });

  group('SrsDocumentType — katalog eksplisit SRS FR-PROF-05 (D-17)', () {
    test('hanya empat jenis yang disebut SRS', () {
      expect(SrsDocumentType.values.length, 4);
      expect(SrsDocumentType.byJenis('transkrip'), isNotNull);
      expect(SrsDocumentType.byJenis('kartu_identitas_pelajar'), isNotNull);
      expect(SrsDocumentType.byJenis('sertifikat_prestasi'), isNotNull);
      expect(SrsDocumentType.byJenis('sertifikat_bahasa'), isNotNull);
      // Jenis katalog lama di luar SRS TIDAK dipetakan ke katalog SRS.
      expect(SrsDocumentType.byJenis('skor_utbk'), isNull);
      expect(SrsDocumentType.byJenis('cv'), isNull);
    });
  });
}
