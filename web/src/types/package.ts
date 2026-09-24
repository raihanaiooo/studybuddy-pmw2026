export interface Package {
  id: string;
  package_name: string;
  session_count: number;
  validity_days: number;
  reschedule_quota: number;
  is_refundable: boolean;
  price: number;
  description: string | null;
  is_active: boolean;
  created_at: string;
}

export type TokenStatus = 'active' | 'used' | 'expired';

export interface Token {
  id: string;
  buddy_id: string;
  package_id: string;
  status: TokenStatus;
  active_date: string;
  expiry_date: string;
  sessions_remaining: number;
  created_at: string;
}

export interface TokenWithRelations extends Token {
  buddy?: { id: string; full_name: string; email: string } | null;
  package?: {
    id: string;
    package_name: string;
    session_count: number;
    price: number;
  } | null;
}

export interface PackageStats {
  totalPackages: number;
  activePackages: number;
  totalTokens: number;
  activeTokens: number;
  totalRevenue: number;
}

export interface PackageFormData {
  package_name: string;
  session_count: number;
  validity_days: number;
  reschedule_quota: number;
  is_refundable: boolean;
  price: number;
  description: string;
  is_active: boolean;
}