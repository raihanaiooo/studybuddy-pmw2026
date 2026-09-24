export type ComplaintCategory =
  | 'connection_issue'
  | 'tutor_absent'
  | 'buddy_absent'
  | 'material_mismatch'
  | 'other';

export type ComplaintStatus =
  | 'pending'
  | 'in_review'
  | 'resolved'
  | 'rejected';

export type ReporterRole = 'buddy' | 'tutor';

export interface Complaint {
  id: string;
  booking_id: string;
  session_id: string | null;
  reporter_id: string;
  reporter_role: ReporterRole;
  category: ComplaintCategory;
  description: string;
  status: ComplaintStatus;
  admin_note: string | null;
  handled_by: string | null;
  handled_at: string | null;
  created_at: string;
}

export interface ComplaintWithRelations extends Complaint {
  reporter?: { id: string; full_name: string; email: string } | null;
  booking?: {
    id: string;
    subject: string;
    session_time: string;
    customer_id: string;
    tutor_id: string;
  } | null;
  handler?: { id: string; full_name: string } | null;
}

export interface ComplaintStats {
  total: number;
  pending: number;
  in_review: number;
  resolved: number;
  rejected: number;
}

export const CATEGORY_LABELS: Record<ComplaintCategory, string> = {
  connection_issue: 'Koneksi Terputus',
  tutor_absent: 'Tutor Tidak Hadir',
  buddy_absent: 'Buddy Tidak Hadir',
  material_mismatch: 'Materi Tidak Sesuai',
  other: 'Lainnya',
};