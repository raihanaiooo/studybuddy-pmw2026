// supabase/functions/create-tutor/index.ts
// Edge Function: membuat akun tutor dari dashboard admin.
// Kredensial service role TIDAK PERNAH dikirim ke browser —
// fungsi ini yang memegangnya via Deno.env.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS });
  }
  if (req.method !== 'POST') {
    return json(405, { error: 'Method tidak diizinkan' });
  }

  try {
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
    const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
      return json(500, { error: 'Konfigurasi server tidak lengkap' });
    }

    const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // 1. Verifikasi pemanggil: Token JWT user Supabase
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return json(401, { error: 'Token autentikasi tidak ditemukan' });
    }
    const token = authHeader.slice('Bearer '.length);
    const { data: { user: caller }, error: authErr } = await supabase.auth.getUser(token);
    if (authErr || !caller) {
      return json(401, { error: 'Token tidak valid atau sudah kedaluwarsa' });
    }

    // 2. Pastikan pemanggil adalah admin
    const { data: callerRow, error: roleErr } = await supabase
      .from('users')
      .select('role')
      .eq('id', caller.id)
      .single();
    if (roleErr || !callerRow) {
      return json(403, { error: 'Gagal memverifikasi peran pemanggil' });
    }
    if ((callerRow as { role: string }).role !== 'admin') {
      return json(403, { error: 'Akses ditolak: hanya admin yang boleh membuat tutor' });
    }

    // 3. Validasi input sebelum menyentuh DB
    const body = await req.json().catch(() => null);
    if (!body || typeof body !== 'object') {
      return json(400, { error: 'Body request tidak valid' });
    }

    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    const fullName = typeof body.full_name === 'string' ? body.full_name.trim() : '';
    const phone = typeof body.phone === 'string' ? body.phone.trim() : null;
    const university = typeof body.university === 'string' ? body.university.trim() : null;
    const bio = typeof body.bio === 'string' ? body.bio.trim() : null;
    const pricePerHour = Number(body.price_per_hour);
    const subjects = Array.isArray(body.subjects)
      ? (body.subjects as unknown[]).filter((s) => typeof s === 'string')
      : [];
    const jenjangDiajar = Array.isArray(body.jenjang_diajar)
      ? (body.jenjang_diajar as unknown[]).filter((s) => typeof s === 'string')
      : [];

    if (!email || !EMAIL_RE.test(email)) {
      return json(400, { error: 'Format email tidak valid' });
    }
    if (!fullName) {
      return json(400, { error: 'Nama lengkap wajib diisi' });
    }
    if (!Number.isFinite(pricePerHour) || pricePerHour <= 0) {
      return json(400, { error: 'Harga per jam harus angka positif' });
    }

    // 4. Buat akun Auth dengan password acak (komunikasi ke email rusak/instal admin)
    const password =
      'tmp-' + crypto.randomUUID().replace(/-/g, '') + 'Aa1';

    const { data: newUser, error: createErr } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName, role: 'tutor' },
    });
    if (createErr || !newUser?.user) {
      return json(400, { error: 'Gagal membuat akun: ' + (createErr?.message ?? 'tidak diketahui') });
    }

    // 5. Ambil id di tabel public.users (sinkron trigger) & insert profil tutors
    const { data: userRow, error: lookupErr } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();
    if (lookupErr || !userRow) {
      // Profil tak bisa dibuat: hapus akun Auth biar tidak yatim
      await supabase.auth.admin.deleteUser(newUser.user.id);
      return json(400, { error: 'Gagal sinkronisasi tabel users; akun di-rollback' });
    }

    const { error: insertErr } = await supabase
      .from('tutors')
      .insert({
        user_id: userRow.id,
        full_name: fullName,
        university,
        bio,
        phone,
        price_per_hour: pricePerHour,
        subjects,
        jenjang_diajar: jenjangDiajar,
        verification_status: 'verified',
        account_status: 'active',
        is_featured: false,
      });
    if (insertErr) {
      await supabase.auth.admin.deleteUser(newUser.user.id);
      return json(400, { error: 'Gagal membuat profil tutor: ' + insertErr.message });
    }

    return json(200, { ok: true, user_id: userRow.id });
  } catch (e) {
    return json(500, { error: e instanceof Error ? e.message : 'Kesalahan server' });
  }
});
