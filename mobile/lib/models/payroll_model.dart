/// Status pencairan honor Tutor (FR-PAYR-03/05)
enum PayrollStatus { belumDibayar, sudahDibayar }

/// Rekap honor bulanan Tutor — 1 slip gaji per periode (FR-PAYR-06,
/// entity PayrollRecord di SRS 4.1)
class PayrollRecordModel {
  final String id;
  final String tutorId;
  final String tutorName;
  final String period; // mis. "September 2026"
  final List<SessionEarningItem> sessions;
  final PayrollStatus status;
  final double totalTransferred;
  final DateTime? transferDate;

  const PayrollRecordModel({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.period,
    required this.sessions,
    this.status = PayrollStatus.belumDibayar,
    this.totalTransferred = 0,
    this.transferDate,
  });

  /// Total hak Tutor sebelum dikurangi yang sudah ditransfer (FR-PAYR-06)
  double get totalHakTutor =>
      sessions.fold(0, (sum, s) => sum + s.hakTutor);

  double get remainingBalance => totalHakTutor - totalTransferred;

  factory PayrollRecordModel.fromMap(Map<String, dynamic> map) =>
      PayrollRecordModel(
        id: map['id'] as String,
        tutorId: map['tutor_id'] as String,
        tutorName: map['tutor_name'] as String,
        period: map['periode'] as String,
        sessions: (map['rincian_sesi'] as List)
            .map((e) => SessionEarningItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        status: PayrollStatus.values.firstWhere(
          (s) => s.name == map['status_transfer'],
          orElse: () => PayrollStatus.belumDibayar,
        ),
        totalTransferred: (map['total_transferred'] as num?)?.toDouble() ?? 0,
        transferDate: map['tanggal_transfer'] != null
            ? DateTime.parse(map['tanggal_transfer'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tutor_id': tutorId,
    'tutor_name': tutorName,
    'periode': period,
    'rincian_sesi': sessions.map((s) => s.toMap()).toList(),
    'status_transfer': status.name,
    'total_transferred': totalTransferred,
    'tanggal_transfer': transferDate?.toIso8601String(),
  };
}

/// Satu baris rincian sesi dalam slip gaji (FR-PAYR-06)
///
/// [ratePerSession] sudah bagian 70% Tutor (FR-PAY-13); 30% perusahaan
/// tidak ditampilkan di slip Tutor.
class SessionEarningItem {
  final DateTime classDate;
  final String buddyName;
  final String material;
  final int sessionCount;
  final double ratePerSession;
  final double deduction;
  final String? deductionNote;

  const SessionEarningItem({
    required this.classDate,
    required this.buddyName,
    required this.material,
    this.sessionCount = 1,
    required this.ratePerSession,
    this.deduction = 0,
    this.deductionNote,
  });

  double get subTotal => sessionCount * ratePerSession;
  double get hakTutor => subTotal - deduction;

  factory SessionEarningItem.fromMap(Map<String, dynamic> map) =>
      SessionEarningItem(
        classDate: DateTime.parse(map['tanggal_kelas'] as String),
        buddyName: map['nama_buddy'] as String,
        material: map['materi'] as String,
        sessionCount: map['jumlah_sesi'] as int? ?? 1,
        ratePerSession: (map['rate_per_sesi'] as num).toDouble(),
        deduction: (map['potongan'] as num?)?.toDouble() ?? 0,
        deductionNote: map['keterangan_potongan'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'tanggal_kelas': classDate.toIso8601String(),
    'nama_buddy': buddyName,
    'materi': material,
    'jumlah_sesi': sessionCount,
    'rate_per_sesi': ratePerSession,
    'potongan': deduction,
    'keterangan_potongan': deductionNote,
  };
}
