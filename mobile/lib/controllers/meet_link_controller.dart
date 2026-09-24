import 'package:get/get.dart';

import '../data/meet_link_repository_supabase.dart';
import '../domain/meet_link_repository.dart';
import 'profile_controller.dart';

class MeetLinkController extends GetxController {
  MeetLinkController({MeetLinkRepository? repository})
    : _repo = repository ?? MeetLinkRepositorySupabase();

  final MeetLinkRepository _repo;

  final RxList<MeetLinkRef> links = <MeetLinkRef>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String? _tutorId;

  @override
  void onInit() {
    super.onInit();
    _autoLoad();
  }

  Future<void> _autoLoad() async {
    // Tunggu ProfileController selesai load tutor profile
    if (!Get.isRegistered<ProfileController>()) return;
    final profileCtrl = Get.find<ProfileController>();
    // Tunggu sampai tutorProfile terisi
    ever(profileCtrl.tutorProfile, (tutor) {
      if (tutor != null && _tutorId != tutor.id) {
        loadFor(tutor.id);
      }
    });
    // Kalau sudah terisi
    final tutor = profileCtrl.tutorProfile.value;
    if (tutor != null) {
      loadFor(tutor.id);
    }
  }

  Future<void> loadFor(String tutorId) async {
    _tutorId = tutorId;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      links.value = await _repo.fetchLinks(tutorId);
    } on MeetLinkBackendMissingException catch (e) {
      links.value = [];
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal memuat link Meet. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addLink({required String meetLink, String? label}) async {
    final tutorId = _tutorId;
    if (tutorId == null) {
      errorMessage.value = 'Tutor ID tidak dikenal.';
      return false;
    }
    if (meetLink.trim().isEmpty) {
      errorMessage.value = 'Link tidak boleh kosong.';
      return false;
    }
    if (!meetLink.startsWith('https://')) {
      errorMessage.value = 'Link harus diawali https://';
      return false;
    }
    isLoading.value = true;
    try {
      final created = await _repo.createLink(
        tutorId: tutorId,
        meetLink: meetLink.trim(),
        label: label,
      );
      links.add(created);
      return true;
    } on MeetLinkBackendMissingException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Gagal menambah link. Coba lagi.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeLink(String linkId) async {
    isLoading.value = true;
    try {
      await _repo.deleteLink(linkId);
      links.removeWhere((l) => l.id == linkId);
    } on MeetLinkBackendMissingException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal menghapus link. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }
}
