import 'payment_gateway.dart';
import '../data/payment_gateway_placeholder.dart';

/// Service pembayaran — dipakai oleh PaymentController.
///
/// Ganti `PaymentGatewayPlaceholder()` dengan implementasi asli
/// (misal `PaymentGatewayShopee()`) kalau provider final sudah diputuskan.
class PaymentService {
  final PaymentGateway _gateway;

  PaymentService({PaymentGateway? gateway})
    : _gateway = gateway ?? PaymentGatewayPlaceholder();

  PaymentGatewayProvider get provider => _gateway.provider;

  Future<PaymentResponse> createPayment({
    required String orderId,
    required double amount,
    required String description,
    String? customerName,
    String? customerEmail,
  }) {
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

  Future<PaymentStatus> checkStatus(String orderId) =>
      _gateway.checkStatus(orderId);

  Stream<PaymentStatus> watchStatus(String orderId) =>
      _gateway.watchStatus(orderId);
}
