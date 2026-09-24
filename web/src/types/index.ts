export type UserRole = 'buddy' | 'tutor' | 'admin';

export interface User {
  id: string;
  email: string;
  full_name: string;
  role: UserRole;
  avatar_url: string | null;
  phone: string | null;
  jenjang: string | null;
  created_at: string;
}

export interface AdminStats {
  totalBookings: number;
  totalRevenue: number;
  totalTutors: number;
  totalBuddies: number;
  pendingVerifications: number;
  pendingReschedules: number;
}