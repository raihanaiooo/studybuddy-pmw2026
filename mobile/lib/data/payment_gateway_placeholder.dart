import 'dart:async';
import '../domain/payment_gateway.dart';

/// Placeholder — TIDAK terhubung ke provider sungguhan.
///
/// Pakai ini sementara sampai provider final diputuskan.
/// Ganti dengan implementasi asli kalau sudah ada.
class PaymentGatewayPlaceholder implements PaymentGateway {
  @override
  PaymentGatewayProvider get provider => PaymentGatewayProvider.shopeePay;

  @override
  Future<PaymentResponse> createPayment(PaymentRequest request) async {
    // Simulasi: return QR palsu
    await Future.delayed(const Duration(milliseconds: 300));
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
    // Simulasi: selalu pending
    return PaymentStatus.pending;
  }

  @override
  Stream<PaymentStatus> watchStatus(String orderId) {
    // Simulasi: stream kosong
    return const Stream.empty();
  }
}
