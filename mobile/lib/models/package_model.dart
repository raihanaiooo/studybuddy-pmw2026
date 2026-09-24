/// Model paket/bundling belajar (SRS 3.4 — Sistem Paket & Token)
///
/// Aturan dari client:
/// - Paket bulanan: 35 hari berlaku
/// - Tidak ada yang lebih dari 35 hari
/// - Kalau hangus, tidak ada refund
class PackageModel {
  final String id;
  final String name;
  final int sessionCount;
  final int validityDays;
  final int rescheduleQuota;
  final bool isRefundable;
  final double price;
  final String description;

  const PackageModel({
    required this.id,
    required this.name,
    required this.sessionCount,
    this.validityDays = 35,
    this.rescheduleQuota = 5,
    this.isRefundable = false,
    required this.price,
    required this.description,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) => PackageModel(
    id: map['id'] as String,
    name: map['package_name'] as String,
    sessionCount: map['session_count'] as int? ?? 0,
    validityDays: map['validity_days'] as int? ?? 35,
    rescheduleQuota: map['reschedule_quota'] as int? ?? 5,
    isRefundable: map['is_refundable'] as bool? ?? false,
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    description: map['description'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'package_name': name,
    'session_count': sessionCount,
    'validity_days': validityDays,
    'reschedule_quota': rescheduleQuota,
    'is_refundable': isRefundable,
    'price': price,
    'description': description,
  };
}
