/// Status tagihan invoice (FR-PAY-05)
enum InvoiceStatus { waiting, paid, expired, cancelled }

/// Data invoice pembayaran satu booking, bisa mencakup multi-sesi
/// (FR-PAY-01, FR-PAY-02, FR-PAY-03)
class InvoiceModel {
  final String id; // format: INV/SB/YYYYMMDD/[ID_PESANAN]
  final String bookingId;
  final String studentName;
  final String studentGrade;
  final String studentSchool;
  final String tutorName;
  final List<InvoiceSessionItem> sessions;
  final double discount;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? paidAt;

  const InvoiceModel({
    required this.id,
    required this.bookingId,
    required this.studentName,
    required this.studentGrade,
    required this.studentSchool,
    required this.tutorName,
    required this.sessions,
    this.discount = 0,
    this.status = InvoiceStatus.waiting,
    required this.createdAt,
    required this.expiresAt,
    this.paidAt,
  });

  double get subtotal => sessions.fold(0, (sum, s) => sum + s.price);
  double get total => (subtotal - discount).clamp(0, double.infinity);

  InvoiceModel copyWith({InvoiceStatus? status, DateTime? paidAt}) =>
      InvoiceModel(
        id: id,
        bookingId: bookingId,
        studentName: studentName,
        studentGrade: studentGrade,
        studentSchool: studentSchool,
        tutorName: tutorName,
        sessions: sessions,
        discount: discount,
        status: status ?? this.status,
        createdAt: createdAt,
        expiresAt: expiresAt,
        paidAt: paidAt ?? this.paidAt,
      );

  factory InvoiceModel.fromMap(Map<String, dynamic> map) => InvoiceModel(
    id: map['invoice_id'] as String,
    bookingId: map['booking_id'] as String,
    studentName: map['student_name'] as String,
    studentGrade: map['student_grade'] as String,
    studentSchool: map['student_school'] as String,
    tutorName: map['tutor_name'] as String,
    sessions: (map['sessions'] as List)
        .map((e) => InvoiceSessionItem.fromMap(e as Map<String, dynamic>))
        .toList(),
    discount: (map['discount'] as num?)?.toDouble() ?? 0,
    status: InvoiceStatus.values.firstWhere(
      (s) => s.name == map['status'],
      orElse: () => InvoiceStatus.waiting,
    ),
    createdAt: DateTime.parse(map['created_at'] as String),
    expiresAt: DateTime.parse(map['expires_at'] as String),
    paidAt: map['paid_at'] != null
        ? DateTime.parse(map['paid_at'] as String)
        : null,
  );

  Map<String, dynamic> toMap() => {
    'invoice_id': id,
    'booking_id': bookingId,
    'student_name': studentName,
    'student_grade': studentGrade,
    'student_school': studentSchool,
    'tutor_name': tutorName,
    'sessions': sessions.map((s) => s.toMap()).toList(),
    'discount': discount,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'paid_at': paidAt?.toIso8601String(),
  };
}

/// Rincian per sesi dalam satu invoice (FR-PAY-03: multi-session)
class InvoiceSessionItem {
  final String subject;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final String timezone;
  final double price;

  const InvoiceSessionItem({
    required this.subject,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    this.timezone = 'WIB',
    required this.price,
  });

  factory InvoiceSessionItem.fromMap(Map<String, dynamic> map) =>
      InvoiceSessionItem(
        subject: map['subject'] as String,
        sessionDate: DateTime.parse(map['session_date'] as String),
        startTime: map['start_time'] as String,
        endTime: map['end_time'] as String,
        timezone: map['timezone'] as String? ?? 'WIB',
        price: (map['price'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
    'subject': subject,
    'session_date': sessionDate.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'timezone': timezone,
    'price': price,
  };
}
