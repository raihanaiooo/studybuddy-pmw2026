import { useState } from 'react';
import { supabase } from '../../lib/supabase';
import { CheckCircle2, MessageCircle } from 'lucide-react';

export function OrderForm() {
  const [loading, setLoading] = useState(false);
  const [successData, setSuccessData] = useState<{ nama: string; wa: string; mapel: string; jenjang: string } | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget);
    const data = Object.fromEntries(formData.entries()) as Record<string, string>;

    const { error } = await supabase.from('manual_orders').insert({
      name: data.nama,
      whatsapp: data.wa,
      subject: data.mapel,
      jenjang: data.jenjang,
      status: 'pending',
    });

    setLoading(false);

    if (error) {
      alert('Gagal mengirim orderan: ' + error.message);
      return;
    }

    setSuccessData({ nama: data.nama, wa: data.wa, mapel: data.mapel, jenjang: data.jenjang });
  }

  function handleWA() {
    if (!successData) return;
    const text = `Halo admin, saya ${successData.nama} ingin les ${successData.mapel} jenjang ${successData.jenjang}.`;
    window.open(`https://wa.me/6281200000000?text=${encodeURIComponent(text)}`, '_blank');
  }

  return (
    <section id="order" className="py-20 md:py-28 bg-[var(--card)]">
      <div className="max-w-6xl mx-auto px-5 grid md:grid-cols-12 gap-10">
        <div className="md:col-span-5">
          <h2 className="text-4xl md:text-6xl font-extrabold leading-[1.02] text-[var(--ink)]">Mulai dari satu form kecil.</h2>
          <p className="mt-5 text-[var(--mute)] leading-relaxed max-w-sm">Isi data singkat, admin kami menghubungi lewat WhatsApp dan menawarkan tutor yang paling cocok. Sesi percobaan gratis.</p>
        </div>

        {successData ? (
          <div className="md:col-span-7 rounded-[2rem] border-2 border-[var(--line)] p-6 md:p-9 bg-[var(--bg)] flex flex-col items-center justify-center text-center">
            <CheckCircle2 size={48} className="text-green-600 mb-4" />
            <h3 className="text-2xl font-bold mb-2 text-[var(--ink)]">Orderan Terkirim!</h3>
            <p className="text-[var(--mute)] mb-6">Data kamu sudah masuk ke sistem kami. Ingin langsung ngobrol dengan admin?</p>
            <button onClick={handleWA} className="inline-flex items-center justify-center gap-2 font-extrabold rounded-2xl py-3 px-6 bg-[#00C853] text-white shadow-[0_5px_0_#00A84A] hover:-translate-y-0.5 hover:shadow-[0_7px_0_#00A84A] transition-all">
              <MessageCircle size={18} /> Hubungi Admin via WhatsApp
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="md:col-span-7 rounded-[2rem] border-2 border-[var(--line)] p-6 md:p-9 grid sm:grid-cols-2 gap-5 bg-[var(--bg)]">

            {/* Input Custom (jangan pakai .inp agar tidak bentrok) */}
            <label className="font-bold text-sm text-[var(--ink)]">Nama
              <input required name="nama" className="w-full mt-2 bg-[var(--card)] border-2 border-[var(--line)] rounded-2xl px-4 py-3 font-semibold text-[var(--ink)] outline-none focus:border-[var(--blue)] transition-colors" placeholder="Nama lengkap" />
            </label>
            <label className="font-bold text-sm text-[var(--ink)]">Nomor WhatsApp
              <input required name="wa" inputMode="tel" className="w-full mt-2 bg-[var(--card)] border-2 border-[var(--line)] rounded-2xl px-4 py-3 font-semibold text-[var(--ink)] outline-none focus:border-[var(--blue)] transition-colors" placeholder="08xxxxxxxxxx" />
            </label>
            <label className="font-bold text-sm text-[var(--ink)]">Mapel
              <select name="mapel" className="w-full mt-2 bg-[var(--card)] border-2 border-[var(--line)] rounded-2xl px-4 py-3 font-semibold text-[var(--ink)] outline-none focus:border-[var(--blue)] transition-colors">
                <option>Matematika</option><option>Fisika</option><option>Kimia</option><option>Biologi</option><option>Bahasa Inggris</option><option>Lainnya</option>
              </select>
            </label>
            <label className="font-bold text-sm text-[var(--ink)]">Jenjang
              <select name="jenjang" className="w-full mt-2 bg-[var(--card)] border-2 border-[var(--line)] rounded-2xl px-4 py-3 font-semibold text-[var(--ink)] outline-none focus:border-[var(--blue)] transition-colors">
                <option>SD</option><option>SMP</option><option>SMA</option><option>Kuliah</option>
              </select>
            </label>

            <div className="sm:col-span-2 flex flex-wrap items-center gap-4 mt-2">
              <button
                type="submit"
                disabled={loading}
                className="inline-flex items-center justify-center gap-2 font-extrabold rounded-2xl py-3 px-6 bg-[var(--blue)] text-white shadow-[0_5px_0_var(--bdark)] hover:-translate-y-0.5 hover:shadow-[0_7px_0_var(--bdark)] active:translate-y-1 active:shadow-none transition-all disabled:opacity-50 disabled:pointer-events-none"
              >
                {loading ? 'Mengirim...' : 'Kirim orderan'}
              </button>
            </div>
          </form>
        )}
      </div>
    </section>
  );
}