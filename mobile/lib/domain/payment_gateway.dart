/// Abstraksi payment gateway — bisa diganti provider kapan saja.
///
/// Implementasi konkret ada di `lib/data/` (misal:
/// `payment_gateway_shopee.dart`, `payment_gateway_midtrans.dart`).
///
/// Cara pakai:
/// 1. Panggil `createPayment()` untuk dapat QR/URL
/// 2. Redirect user ke halaman payment (atau tampilkan QR)
/// 3. Tunggu callback/webhook dari provider
/// 4. Cek status lewat `checkStatus()` (polling) atau tunggu realtime

enum PaymentGatewayProvider {
  shopeePay,
  midtrans,
  xendit,
  // ... tambah kalau perlu
}

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
  final String? qrString; // untuk QRIS
  final String? redirectUrl; // untuk redirect
  final String? deeplink; // untuk e-wallet
  final String? providerRef; // ID transaksi di provider
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
  /// Provider yang dipakai
  PaymentGatewayProvider get provider;

  /// Buat pembayaran — return QR/URL yang bisa ditampilkan
  Future<PaymentResponse> createPayment(PaymentRequest request);

  /// Cek status pembayaran (polling)
  Future<PaymentStatus> checkStatus(String orderId);

  /// Cek apakah pembayaran sudah lunas (callback dari webhook)
  /// — dipakai jika Supabase Realtime aktif
  Stream<PaymentStatus> watchStatus(String orderId);
}

class PaymentGatewayException implements Exception {
  final String message;
  final Object? cause;

  const PaymentGatewayException(this.message, [this.cause]);

  @override
  String toString() => 'PaymentGatewayException: $message';
}
