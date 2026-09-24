import type {
  PaymentGateway,
  PaymentRequest,
  PaymentResponse,
} from './payment-gateway';
import { PaymentProvider, PaymentStatus } from './payment-gateway';

export class PaymentGatewayPlaceholder implements PaymentGateway {
  provider = PaymentProvider.SHOPEE_PAY;

  async createPayment(request: PaymentRequest): Promise<PaymentResponse> {
    await new Promise((resolve) => setTimeout(resolve, 300));
    return {
      orderId: request.orderId,
      qrString: `PLACEHOLDER_QR_${request.orderId}`,
      redirectUrl: `https://example.com/pay/${request.orderId}`,
      providerRef: `PLACEHOLDER_REF_${Date.now()}`,
      expiresAt: new Date(Date.now() + 15 * 60 * 1000),
      status: PaymentStatus.PENDING,
    };
  }

  async checkStatus(_orderId: string): Promise<PaymentStatus> {
    return PaymentStatus.PENDING;
  }
}