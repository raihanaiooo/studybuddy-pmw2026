import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { LogIn, Mail, Lock, Eye, EyeOff } from 'lucide-react';

export function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // State buat show/hide password
  const [showPassword, setShowPassword] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password });
      if (authError) throw authError;

      const { data: user, error: userError } = await supabase.from('users').select('role').eq('id', data.user.id).single();
      if (userError) throw userError;

      if (user?.role !== 'admin') {
        await supabase.auth.signOut();
        throw new Error('Akun ini bukan admin.');
      }
      navigate('/dashboard');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login gagal');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex bg-[var(--bg)]">
      {/* KIRI: Branding */}
      <div className="hidden lg:flex w-1/2 bg-[var(--blue)] flex-col justify-center p-16 text-white relative overflow-hidden">
        <div className="relative z-10">
          <div className="w-16 h-16 bg-white/20 rounded-2xl flex items-center justify-center text-3xl font-extrabold mb-8 backdrop-blur-md">SB</div>
          <h1 className="text-4xl font-extrabold mb-4 leading-tight">Kelola Study Buddy dengan Mudah.</h1>
          <p className="text-white/80 text-lg max-w-md">Pantau orderan, verifikasi tutor, dan atur konten landing page dalam satu dashboard.</p>
        </div>
        <div className="absolute -bottom-20 -right-20 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute top-20 -left-20 w-72 h-72 bg-white/10 rounded-full blur-2xl"></div>
      </div>

      {/* KANAN: Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-6">
        <div className="w-full max-w-md">
          <div className="lg:hidden w-12 h-12 bg-[var(--blue)] rounded-xl flex items-center justify-center text-xl font-extrabold text-white mb-6">SB</div>
          <h2 className="text-2xl font-extrabold text-[var(--ink)] mb-2">Selamat Datang Kembali</h2>
          <p className="text-[var(--mute)] mb-8">Masuk ke akun Admin Study Buddy kamu.</p>

          <form onSubmit={handleSubmit} className="space-y-4">

            {/* Input Email */}
            <div>
              <label className="block text-sm font-bold text-[var(--ink)] mb-1.5">Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)]" size={18} />
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  required
                  placeholder="admin@studybuddy.test"
                  className="inp !pl-10" // <--- FIX: pakai !pl-10 biar padding-nya nempel
                />
              </div>
            </div>

            {/* Input Password */}
            <div>
              <label className="block text-sm font-bold text-[var(--ink)] mb-1.5">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)]" size={18} />
                <input
                  type={showPassword ? "text" : "password"} // <--- Tipe dinamis
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  required
                  placeholder="••••••••"
                  className="inp !pl-10 !pr-10" // <--- FIX: padding kiri & kanan
                />
                {/* Tombol Toggle Mata */}
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--mute)] hover:text-[var(--ink)]"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {error && <div className="p-3 bg-red-100 text-red-700 rounded-lg text-sm font-semibold">{error}</div>}

            <button type="submit" disabled={loading} className="btn btn-p w-full justify-center py-3 mt-2">
              {loading ? 'Memproses...' : <><LogIn size={18} /> Masuk</>}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}