// Export value (const object) + type (union)
export {
  PaymentProvider,
  PaymentStatus,
  PaymentGatewayError,
} from './payment-gateway';

// Export type-only (interface & type alias)
export type {
  PaymentGateway,
  PaymentRequest,
  PaymentResponse,
} from './payment-gateway';

// Service & placeholder
export { PaymentService, paymentService } from './payment-service';
export { PaymentGatewayPlaceholder } from './placeholder';