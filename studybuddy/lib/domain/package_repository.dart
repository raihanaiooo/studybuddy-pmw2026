class PackageRef {
  final String id;
  final String packageName;
  final int sessionCount;
  final int validityDays;
  final int rescheduleQuota;
  final bool isRefundable;
  final double price;
  final String? description;
  final bool isActive;

  const PackageRef({
    required this.id,
    required this.packageName,
    required this.sessionCount,
    required this.validityDays,
    required this.rescheduleQuota,
    required this.isRefundable,
    required this.price,
    this.description,
    this.isActive = true,
  });
}

class TokenRef {
  final String id;
  final String buddyId;
  final String packageId;
  final String status;
  final DateTime activeDate;
  final DateTime expiryDate;
  final int sessionsRemaining;

  const TokenRef({
    required this.id,
    required this.buddyId,
    required this.packageId,
    required this.status,
    required this.activeDate,
    required this.expiryDate,
    required this.sessionsRemaining,
  });

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
}

abstract class PackageRepository {
  Future<List<PackageRef>> fetchActivePackages();
  Future<List<TokenRef>> fetchMyTokens(String buddyId);
  Future<TokenRef> createToken({
    required String buddyId,
    required String packageId,
    required int sessionCount,
    required int validityDays,
  });
  Future<void> consumeToken(String tokenId);
  Future<void> expireOldTokens();
}
