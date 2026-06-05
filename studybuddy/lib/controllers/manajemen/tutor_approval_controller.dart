import 'package:get/get.dart';
import '../../shared/constants/prototype.dart';

/// Model untuk pending tutor application
class TutorApplication {
  final String id;
  final String fullName;
  final String email;
  final String university;
  final String gpa;
  final List<String> subjects;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime appliedAt;

  TutorApplication({
    required this.id,
    required this.fullName,
    required this.email,
    required this.university,
    required this.gpa,
    required this.subjects,
    required this.status,
    required this.appliedAt,
  });
}

/// Controller untuk approval tutor oleh manajemen
class TutorApprovalController extends GetxController {
  final RxList<TutorApplication> applications = <TutorApplication>[].obs;
  final RxString filterStatus = 'pending'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  void loadApplications() {
    isLoading.value = true;
    if (kUseMock) {
      applications.value = [
        TutorApplication(
          id: 'app1',
          fullName: 'Muhammad Rizky',
          email: 'rizky@ugm.ac.id',
          university: 'Universitas Gadjah Mada',
          gpa: '3.72',
          subjects: ['Kimia Organik', 'Biokimia'],
          status: 'pending',
          appliedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        TutorApplication(
          id: 'app2',
          fullName: 'Laila Nur Fadhilah',
          email: 'laila@ub.ac.id',
          university: 'Universitas Brawijaya',
          gpa: '3.89',
          subjects: ['Kalkulus', 'Aljabar Linear'],
          status: 'pending',
          appliedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        TutorApplication(
          id: 'app3',
          fullName: 'Ahmad Fauzi',
          email: 'fauzi@its.ac.id',
          university: 'Institut Teknologi Sepuluh Nopember',
          gpa: '3.95',
          subjects: ['Pemrograman Python', 'Machine Learning'],
          status: 'pending',
          appliedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TutorApplication(
          id: 'app4',
          fullName: 'Siti Nurhaliza',
          email: 'siti@unpad.ac.id',
          university: 'Universitas Padjadjaran',
          gpa: '3.65',
          subjects: ['Ekonomi Mikro', 'Ekonomi Makro'],
          status: 'approved',
          appliedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        TutorApplication(
          id: 'app5',
          fullName: 'Budi Setiawan',
          email: 'budi@undip.ac.id',
          university: 'Universitas Diponegoro',
          gpa: '3.45',
          subjects: ['Hukum Perdata'],
          status: 'rejected',
          appliedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
    }
    isLoading.value = false;
  }

  List<TutorApplication> get filtered {
    if (filterStatus.value == 'all') return applications;
    return applications.where((a) => a.status == filterStatus.value).toList();
  }

  int get pendingCount =>
      applications.where((a) => a.status == 'pending').length;

  void approveApplication(String id) {
    final index = applications.indexWhere((a) => a.id == id);
    if (index != -1) {
      applications[index] = TutorApplication(
        id: applications[index].id,
        fullName: applications[index].fullName,
        email: applications[index].email,
        university: applications[index].university,
        gpa: applications[index].gpa,
        subjects: applications[index].subjects,
        status: 'approved',
        appliedAt: applications[index].appliedAt,
      );
      applications.refresh();
      Get.snackbar(
        'Tutor Disetujui',
        '${applications[index].fullName} telah menjadi tutor',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void rejectApplication(String id) {
    final index = applications.indexWhere((a) => a.id == id);
    if (index != -1) {
      applications[index] = TutorApplication(
        id: applications[index].id,
        fullName: applications[index].fullName,
        email: applications[index].email,
        university: applications[index].university,
        gpa: applications[index].gpa,
        subjects: applications[index].subjects,
        status: 'rejected',
        appliedAt: applications[index].appliedAt,
      );
      applications.refresh();
      Get.snackbar(
        'Tutor Ditolak',
        'Pendaftaran ${applications[index].fullName} ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
