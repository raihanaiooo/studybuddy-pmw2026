/// Model token belajar hasil pembelian paket, 1 token = 1 sesi (FR-PKG-02)
class TokenModel {
  final String id;
  final String buddyId;
  final String packageId;
  final String status; // 'active' | 'used' | 'expired'
  final DateTime activeDate;
  final DateTime expiryDate;

  const TokenModel({
    required this.id,
    required this.buddyId,
    required this.packageId,
    required this.status,
    required this.activeDate,
    required this.expiryDate,
  });

  factory TokenModel.fromMap(Map<String, dynamic> map) => TokenModel(
    id: map['id'] as String,
    buddyId: map['buddy_id'] as String,
    packageId: map['package_id'] as String,
    status: map['status'] as String? ?? 'active',
    activeDate: map['tanggal_aktif'] != null
        ? DateTime.parse(map['tanggal_aktif'] as String)
        : DateTime.now(),
    expiryDate: map['tanggal_hangus'] != null
        ? DateTime.parse(map['tanggal_hangus'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'buddy_id': buddyId,
    'package_id': packageId,
    'status': status,
    'tanggal_aktif': activeDate.toIso8601String(),
    'tanggal_hangus': expiryDate.toIso8601String(),
  };

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
}
