import type {
  PaymentGateway,
  PaymentRequest,
  PaymentResponse,
} from './payment-gateway';
import { PaymentProvider, PaymentStatus } from './payment-gateway';
import { PaymentGatewayPlaceholder } from './placeholder';

export class PaymentService {
  private gateway: PaymentGateway;

  constructor(gateway?: PaymentGateway) {
    this.gateway = gateway ?? new PaymentGatewayPlaceholder();
  }

  get provider(): PaymentProvider {
    return this.gateway.provider;
  }

  async createPayment(request: PaymentRequest): Promise<PaymentResponse> {
    return this.gateway.createPayment(request);
  }

  async checkStatus(orderId: string): Promise<PaymentStatus> {
    return this.gateway.checkStatus(orderId);
  }
}

export const paymentService = new PaymentService();