import 'dart:async';
import '../domain/payment_gateway.dart';

/// Implementasi placeholder — TIDAK terhubung ke provider sungguhan.
///
/// Pakai ini sementara sampai provider final diputuskan.
/// Ganti dengan `payment_gateway_shopee.dart` atau `payment_gateway_midtrans.dart`
/// kalau sudah ada.
class PaymentGatewayPlaceholder implements PaymentGateway {
  @override
  PaymentGatewayProvider get provider => PaymentGatewayProvider.shopeePay;

  @override
  Future<PaymentResponse> createPayment(PaymentRequest request) async {
    // Simulasi: langsung return QR palsu
    return PaymentResponse(
      orderId: request.orderId,
      qrString: 'PLACEHOLDER_QR_${request.orderId}',
      redirectUrl: 'https://example.com/pay/${request.orderId}',
      providerRef: 'PLACEHOLDER_REF_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      status: PaymentStatus.pending,
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String orderId) async {
    // Simulasi: cek di Supabase (tabel payments)
    // Untuk sekarang, selalu return pending
    return PaymentStatus.pending;
  }

  @override
  Stream<PaymentStatus> watchStatus(String orderId) {
    // Simulasi: stream kosong
    return const Stream.empty();
  }
}
