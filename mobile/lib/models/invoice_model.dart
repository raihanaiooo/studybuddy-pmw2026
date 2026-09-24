import 'package:flutter/material.dart';

enum InvoiceStatus { waiting, paid, expired, cancelled }

class InvoiceSessionItem {
  final String subject;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final double price;

  const InvoiceSessionItem({
    required this.subject,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'subject': subject,
    'session_date': sessionDate.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'price': price,
  };
}

class InvoiceModel {
  final String id;
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

  double get subtotal => sessions.fold(0.0, (sum, s) => sum + s.price);

  double get total => subtotal - discount;

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
}
