export const PaymentProvider = {
  SHOPEE_PAY: 'shopee_pay',
  MIDTRANS: 'midtrans',
  XENDIT: 'xendit',
} as const;

export type PaymentProvider =
  (typeof PaymentProvider)[keyof typeof PaymentProvider];

export const PaymentStatus = {
  PENDING: 'pending',
  SUCCESS: 'success',
  FAILED: 'failed',
  EXPIRED: 'expired',
} as const;

export type PaymentStatus =
  (typeof PaymentStatus)[keyof typeof PaymentStatus];

// ============================================
// Interface
// ============================================

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

// ============================================
// Error class
// ============================================

export class PaymentGatewayError extends Error {
  cause?: unknown;

  constructor(message: string, cause?: unknown) {
    super(message);
    this.name = 'PaymentGatewayError';
    this.cause = cause;
  }
}