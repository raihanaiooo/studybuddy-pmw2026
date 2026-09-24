import { supabase } from '../supabase';
import type {
  Package,
  PackageFormData,
  PackageStats,
  TokenWithRelations,
  TokenStatus,
} from '../../types/package';

// ============================================
// PACKAGES
// ============================================

export async function fetchPackages(
  includeInactive = false
): Promise<Package[]> {
  let query = supabase
    .from('packages')
    .select('*')
    .order('created_at', { ascending: false });

  if (!includeInactive) {
    query = query.eq('is_active', true);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as Package[];
}

export async function fetchPackageById(id: string): Promise<Package | null> {
  const { data, error } = await supabase
    .from('packages')
    .select('*')
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as Package;
}

export async function createPackage(data: PackageFormData): Promise<Package> {
  const { data: created, error } = await supabase
    .from('packages')
    .insert(data)
    .select()
    .single();

  if (error) throw error;
  return created as Package;
}

export async function updatePackage(
  id: string,
  data: Partial<PackageFormData>
): Promise<Package> {
  const { data: updated, error } = await supabase
    .from('packages')
    .update(data)
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return updated as Package;
}

export async function togglePackageActive(
  id: string,
  isActive: boolean
): Promise<void> {
  const { error } = await supabase
    .from('packages')
    .update({ is_active: isActive })
    .eq('id', id);

  if (error) throw error;
}

// ============================================
// TOKENS
// ============================================

export async function fetchTokens(
  status?: TokenStatus | 'all'
): Promise<TokenWithRelations[]> {
  let query = supabase
    .from('tokens')
    .select(
      `
      *,
      buddy:users!tokens_buddy_id_fkey(id, full_name, email),
      package:packages!tokens_package_id_fkey(id, package_name, session_count, price)
    `
    )
    .order('created_at', { ascending: false });

  if (status && status !== 'all') {
    query = query.eq('status', status);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as TokenWithRelations[];
}

export async function fetchTokenById(
  id: string
): Promise<TokenWithRelations | null> {
  const { data, error } = await supabase
    .from('tokens')
    .select(
      `
      *,
      buddy:users!tokens_buddy_id_fkey(id, full_name, email),
      package:packages!tokens_package_id_fkey(id, package_name, session_count, price)
    `
    )
    .eq('id', id)
    .single();

  if (error) throw error;
  return data as TokenWithRelations;
}

// ============================================
// STATS
// ============================================

export async function fetchPackageStats(): Promise<PackageStats> {
  const [packagesRes, tokensRes] = await Promise.all([
    supabase.from('packages').select('is_active'),
    supabase.from('tokens').select('status, package:packages!tokens_package_id_fkey(price)'),
  ]);

  if (packagesRes.error) throw packagesRes.error;
  if (tokensRes.error) throw tokensRes.error;

  const packages = packagesRes.data ?? [];
  const tokens = tokensRes.data ?? [];

  let totalRevenue = 0;
  let activeTokens = 0;

  for (const t of tokens) {
    if (t.status === 'active') activeTokens += 1;
    // Revenue dari paket yang dibeli (anggap semua token = 1 pembelian)
    const pkg = (t as any).package;
    if (pkg?.price) totalRevenue += Number(pkg.price);
  }

  return {
    totalPackages: packages.length,
    activePackages: packages.filter((p) => p.is_active).length,
    totalTokens: tokens.length,
    activeTokens,
    totalRevenue,
  };
}