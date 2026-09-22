/// Model paket/bundling belajar sesuai SRS 3.4 (Sistem Paket & Token)
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
    required this.validityDays,
    required this.rescheduleQuota,
    required this.isRefundable,
    required this.price,
    required this.description,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) => PackageModel(
    id: map['id'] as String,
    name: map['nama_paket'] as String,
    sessionCount: map['jumlah_sesi'] as int? ?? 0,
    validityDays: map['masa_berlaku_hari'] as int? ?? 0,
    rescheduleQuota: map['kuota_reschedule'] as int? ?? 0,
    isRefundable: map['is_refundable'] as bool? ?? true,
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    description: map['description'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama_paket': name,
    'jumlah_sesi': sessionCount,
    'masa_berlaku_hari': validityDays,
    'kuota_reschedule': rescheduleQuota,
    'is_refundable': isRefundable,
    'price': price,
    'description': description,
  };
}
