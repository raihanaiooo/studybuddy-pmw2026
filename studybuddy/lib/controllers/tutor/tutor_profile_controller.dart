import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/constants/prototype.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/constants/supabase_constants.dart';
import '../../models/tutor_model.dart';
import 'tutor_dashboard_controller.dart';

class TutorProfileController extends GetxController {
  final _dashboard = Get.find<TutorDashboardController>();

  final Rx<TutorModel?> profile = Rx<TutorModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString saveError = ''.obs;
  final RxBool saveSuccess = false.obs;

  // Form controllers
  late final TextEditingController gmeetCurrentCtrl;
  late final TextEditingController gmeetNewCtrl;
  late final TextEditingController bioCtrl;

  @override
  void onInit() {
    super.onInit();
    profile.value = _dashboard.tutorProfile.value;

    gmeetCurrentCtrl = TextEditingController(
      text: profile.value?.gmeetLink ?? '',
    );
    gmeetNewCtrl = TextEditingController();
    bioCtrl = TextEditingController(text: profile.value?.bio ?? '');
  }

  @override
  void onClose() {
    gmeetCurrentCtrl.dispose();
    gmeetNewCtrl.dispose();
    bioCtrl.dispose();
    super.onClose();
  }

  bool get hasNewGmeetLink => gmeetNewCtrl.text.trim().isNotEmpty;

  Future<void> saveProfile() async {
    saveError.value = '';
    saveSuccess.value = false;

    final tutorId = profile.value?.id;
    if (tutorId == null) return;

    final newLink = gmeetNewCtrl.text.trim();
    final newBio = bioCtrl.text.trim();

    if (newLink.isNotEmpty && !newLink.contains('meet.google.com')) {
      saveError.value = 'Link Google Meet tidak valid';
      return;
    }

    isSaving.value = true;
    try {
      final updates = <String, dynamic>{
        'bio': newBio,
        if (newLink.isNotEmpty) 'gmeet_link': newLink,
      };

      if (!kUseMock) {
        await SupabaseService.client
            .from(SupabaseConstants.tableTutors)
            .update(updates)
            .eq('id', tutorId);
      }

      // Update local state
      if (newLink.isNotEmpty) {
        gmeetCurrentCtrl.text = newLink;
        gmeetNewCtrl.clear();
      }

      saveSuccess.value = true;
      Get.snackbar(
        'Berhasil',
        'Profil berhasil disimpan',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      saveError.value = 'Gagal menyimpan profil';
    } finally {
      isSaving.value = false;
    }
  }
}
