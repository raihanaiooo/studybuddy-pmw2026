import 'payment_gateway.dart';

/// Service yang dipakai oleh controller (BookingController, PaymentController)
/// — abstraksi di sini, implementasi konkret bisa diganti.
class PaymentService {
  final PaymentGateway _gateway;

  PaymentService({PaymentGateway? gateway})
    : _gateway = gateway ?? PaymentGatewayPlaceholder();

  /// Buat pembayaran untuk booking
  Future<PaymentResponse> createPayment({
    required String orderId,
    required double amount,
    required String description,
    String? customerName,
    String? customerEmail,
  }) async {
    return _gateway.createPayment(
      PaymentRequest(
        orderId: orderId,
        amount: amount,
        description: description,
        customerName: customerName,
        customerEmail: customerEmail,
      ),
    );
  }

  /// Cek status pembayaran (polling)
  Future<PaymentStatus> checkStatus(String orderId) =>
      _gateway.checkStatus(orderId);

  /// Watch status (realtime)
  Stream<PaymentStatus> watchStatus(String orderId) =>
      _gateway.watchStatus(orderId);
}
