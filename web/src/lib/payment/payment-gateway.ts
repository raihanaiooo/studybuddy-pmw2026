export enum PaymentProvider {
  SHOPEE_PAY = 'shopee_pay',
  MIDTRANS = 'midtrans',
  XENDIT = 'xendit',
}

export enum PaymentStatus {
  PENDING = 'pending',
  SUCCESS = 'success',
  FAILED = 'failed',
  EXPIRED = 'expired',
}

export interface PaymentRequest {
  orderId: string;
  amount: number;
  description: string;
  customerName?: string;
  customerEmail?: string;
}

export interface PaymentResponse {
  orderId: string;
  qrString?: string;
  redirectUrl?: string;
  deeplink?: string;
  providerRef?: string;
  expiresAt: Date;
  status: PaymentStatus;
}

export interface PaymentGateway {
  provider: PaymentProvider;
  createPayment(request: PaymentRequest): Promise<PaymentResponse>;
  checkStatus(orderId: string): Promise<PaymentStatus>;
}