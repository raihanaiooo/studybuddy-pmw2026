import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../data/package_repository_supabase.dart';
import '../domain/package_repository.dart';
import '../models/package_model.dart';
import '../models/token_model.dart';

class PackageController extends GetxController {
  PackageController({PackageRepository? repository})
    : _repo = repository ?? PackageRepositorySupabase();

  final PackageRepository _repo;
  final _authService = AuthService();

  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxList<TokenModel> myTokens = <TokenModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
    fetchMyTokens();
  }

  Future<void> fetchPackages() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final refs = await _repo.fetchActivePackages();
      packages.value = refs.map(_toPackageModel).toList();
    } catch (e) {
      print('PackageController.fetchPackages error: $e');
      errorMessage.value = 'Gagal memuat katalog paket.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyTokens() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;
      final refs = await _repo.fetchMyTokens(user.id);
      myTokens.value = refs.map(_toTokenModel).toList();
    } catch (e) {
      print('PackageController.fetchMyTokens error: $e');
    }
  }

  PackageModel? packageById(String id) =>
      packages.firstWhereOrNull((p) => p.id == id);

  /// Terbitkan token baru begitu pembayaran paket Lunas (FR-PKG-02)
  Future<void> grantToken(PackageModel package) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;
      final ref = await _repo.createToken(
        buddyId: user.id,
        packageId: package.id,
        sessionCount: package.sessionCount,
        validityDays: package.validityDays,
      );
      myTokens.insert(0, _toTokenModel(ref));
    } catch (e) {
      print('PackageController.grantToken error: $e');
      Get.snackbar('Gagal', 'Token tidak tersimpan. Coba lagi.');
    }
  }

  PackageModel _toPackageModel(PackageRef r) => PackageModel(
    id: r.id,
    name: r.packageName,
    sessionCount: r.sessionCount,
    validityDays: r.validityDays,
    rescheduleQuota: r.rescheduleQuota,
    isRefundable: r.isRefundable,
    price: r.price,
    description: r.description ?? '',
  );

  TokenModel _toTokenModel(TokenRef r) => TokenModel(
    id: r.id,
    buddyId: r.buddyId,
    packageId: r.packageId,
    status: r.status,
    activeDate: r.activeDate,
    expiryDate: r.expiryDate,
    sessionsRemaining: r.sessionsRemaining,
  );

  /// Cari token yang bisa dipakai booking (FIFO: paling cepat kadaluarsa).
  /// Mengembalikan null kalau tidak ada token yang usable.
  Future<TokenModel?> pickTokenForBooking() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return null;
      final ref = await _repo.findUsableToken(user.id);
      if (ref == null) return null;
      return _toTokenModel(ref);
    } catch (e) {
      print('PackageController.pickTokenForBooking error: $e');
      return null;
    }
  }

  /// Refresh myTokens setelah token dipakai
  Future<void> refreshTokens() async {
    await fetchMyTokens();
  }
}
