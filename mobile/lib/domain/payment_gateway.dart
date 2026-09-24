/// Abstraksi payment gateway — bisa diganti provider kapan saja.
///
/// Implementasi konkret ada di `lib/data/`:
/// - `payment_gateway_placeholder.dart` (sementara)
/// - `payment_gateway_shopee.dart` (nanti)
/// - `payment_gateway_midtrans.dart` (nanti)
///
/// Cara pakai:
/// 1. `createPayment()` → dapat QR/URL
/// 2. Tampilkan ke user
/// 3. Tunggu callback/webhook dari provider
/// 4. `checkStatus()` untuk polling, atau `watchStatus()` untuk realtime

enum PaymentGatewayProvider { shopeePay, midtrans, xendit }

enum PaymentStatus { pending, success, failed, expired }

class PaymentRequest {
  final String orderId;
  final double amount;
  final String description;
  final String? customerName;
  final String? customerEmail;

  const PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.description,
    this.customerName,
    this.customerEmail,
  });
}

class PaymentResponse {
  final String orderId;
  final String? qrString;
  final String? redirectUrl;
  final String? deeplink;
  final String? providerRef;
  final DateTime expiresAt;
  final PaymentStatus status;

  const PaymentResponse({
    required this.orderId,
    this.qrString,
    this.redirectUrl,
    this.deeplink,
    this.providerRef,
    required this.expiresAt,
    this.status = PaymentStatus.pending,
  });
}

abstract class PaymentGateway {
  PaymentGatewayProvider get provider;
  Future<PaymentResponse> createPayment(PaymentRequest request);
  Future<PaymentStatus> checkStatus(String orderId);
  Stream<PaymentStatus> watchStatus(String orderId);
}

class PaymentGatewayException implements Exception {
  final String message;
  final Object? cause;

  const PaymentGatewayException(this.message, [this.cause]);

  @override
  String toString() => 'PaymentGatewayException: $message';
}
