import 'package:get/get.dart';
import '../models/package_model.dart';
import '../models/token_model.dart';

/// Controller katalog paket & token belajar (FR-PKG-01..07)
///
/// Masih pakai dummy data mengikuti alur contract-first tim (lihat SRS Bab 6):
/// tinggal ganti isi fetchPackages()/fetchMyTokens() dengan query Supabase
/// begitu Raihana menuliskan kontrak fungsi untuk modul Paket & Token.
class PackageController extends GetxController {
  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxList<TokenModel> myTokens = <TokenModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
    fetchMyTokens();
  }

  Future<void> fetchPackages() async {
    isLoading.value = true;
    packages.value = _dummyPackages;
    isLoading.value = false;
  }

  Future<void> fetchMyTokens() async {
    myTokens.value = _dummyTokens;
  }

  PackageModel? packageById(String id) =>
      packages.firstWhereOrNull((p) => p.id == id);

  static final List<PackageModel> _dummyPackages = [
    const PackageModel(
      id: 'pkg-terset',
      name: 'Bundling Terset',
      sessionCount: 3,
      validityDays: 7,
      rescheduleQuota: 0,
      isRefundable: true,
      price: 150000,
      description: 'Paket 3 sesi fleksibel, cocok untuk kebutuhan mendadak.',
    ),
    const PackageModel(
      id: 'pkg-bulanan-12',
      name: 'Bundling Bulanan (12 Sesi)',
      sessionCount: 12,
      validityDays: 35,
      rescheduleQuota: 3,
      isRefundable: true,
      price: 550000,
      description:
          'Belajar rutin sebulan penuh, 12 sesi dengan tutor pilihan.',
    ),
    const PackageModel(
      id: 'pkg-snbt-satset',
      name: 'Bundling SNBT — Satset',
      sessionCount: 3,
      validityDays: 7,
      rescheduleQuota: 1,
      isRefundable: true,
      price: 200000,
      description: 'Persiapan kilat UTBK, 3 sesi intensif.',
    ),
    const PackageModel(
      id: 'pkg-snbt-juara',
      name: 'Bundling SNBT — Juara',
      sessionCount: 7,
      validityDays: 14,
      rescheduleQuota: 1,
      isRefundable: true,
      price: 420000,
      description: 'Persiapan UTBK menyeluruh, 7 sesi terjadwal.',
    ),
    const PackageModel(
      id: 'pkg-snbt-sks',
      name: 'Bundling SNBT — SKS',
      sessionCount: 21,
      validityDays: 35,
      rescheduleQuota: 3,
      isRefundable: true,
      price: 1100000,
      description: 'Program UTBK jangka panjang, 21 sesi lengkap.',
    ),
    const PackageModel(
      id: 'pkg-juara-snbt',
      name: 'Bundling Juara SNBT',
      sessionCount: 7,
      validityDays: 7,
      rescheduleQuota: 0,
      isRefundable: false,
      price: 500000,
      description:
          '7 sesi + 1 paket Soal TO. Non-refundable tanpa pengecualian.',
    ),
  ];

  static final List<TokenModel> _dummyTokens = [
    TokenModel(
      id: 'tok-1',
      buddyId: 'me',
      packageId: 'pkg-bulanan-12',
      status: 'active',
      activeDate: DateTime.now().subtract(const Duration(days: 5)),
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
  ];
}
