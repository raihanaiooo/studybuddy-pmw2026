import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Loader2, Star } from 'lucide-react';

const MAPEL_LABELS: Record<string, string> = {
  mtk: 'Matematika',
  fis: 'Fisika',
  ing: 'B. Inggris',
  sd: 'SD',
  smp: 'SMP',
  sma: 'SMA'
};

export function TutorFinder() {
  const [tutors, setTutors] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState({ mapel: 'mtk', jenjang: 'sma', budget: '150' });

  useEffect(() => {
    const fetchTutors = async () => {
      setLoading(true);
      // Ambil tutor yang di-featured di landing page
      const { data, error } = await supabase
        .from('tutors')
        .select('*')
        .eq('is_featured', true)
        .limit(3);

      if (data && !error) {
        // Sesuaikan format data DB ke format UI
        const formatted = data.map((t, i) => {
          // Konversi harga: jika price_per_hour = 130000, jadi 130 (untuk ditampilin "Rp130rb")
          const priceNum = t.price_per_hour ? t.price_per_hour / 1000 : 100;

          // Buat background warna selang-seling
          const colors = [
            { bg: 'bg-[var(--blue)]', text: 'text-white' },
            { bg: 'bg-[var(--bdark)]', text: 'text-white' },
            { bg: 'bg-[var(--yel)]', text: 'text-[var(--ink)]' }
          ];
          const color = colors[i % colors.length];

          return {
            id: t.id,
            initials: t.full_name ? t.full_name.substring(0, 2).toUpperCase() : 'TR',
            name: t.full_name,
            campus: `${t.university || 'Kampus'} · ${t.bio?.split('.')[0] || 'Tutor'}`,
            badge: `Cocok · ${t.featured_match_percent || 95}%`,
            desc: t.featured_reason || 'Tutor berpengalaman dan siap membantu persiapan ujianmu.',
            price: priceNum.toString(),
            rating: t.rating ? t.rating.toString() : '5.0',
            // Pastikan mapel di DB cocok dengan filter (mtk, fis, dll)
            mapel: t.subjects?.length > 0 ? t.subjects : ['mtk'],
            jenjang: t.jenjang_diajar?.length > 0 ? t.jenjang_diajar : ['sma'],
            bg: color.bg,
            text: color.text
          };
        });
        setTutors(formatted);
      }
      setLoading(false);
    };
    fetchTutors();
  }, []);

  // Filter Tutor berdasarkan state
  const filteredTutors = tutors.filter(t =>
    t.mapel.some((m: string) => m.toLowerCase().includes(filter.mapel.toLowerCase())) &&
    t.jenjang.some((j: string) => j.toLowerCase().includes(filter.jenjang.toLowerCase())) &&
    +t.price <= +filter.budget
  );

  return (
    <section id="tutor" className="py-20 md:py-28 bg-[var(--card)]">
      <div className="max-w-6xl mx-auto px-5">
        <div className="grid md:grid-cols-12 gap-8 mb-12">
          <h2 className="md:col-span-7 text-4xl md:text-6xl font-extrabold leading-[1.02] text-[var(--ink)]">
            Sistem kami memilih tutor, kamu tinggal belajar.
          </h2>
          <p className="md:col-span-4 md:col-start-9 text-[var(--mute)] leading-relaxed self-end">
            Isi tiga hal saja. Study Buddy mencocokkan gaya mengajar, jadwal, dan harga, lalu mengurutkan tutor dari yang paling pas.
          </p>
        </div>

        <div className="rounded-[2rem] border-2 border-[var(--line)] p-5 md:p-8 bg-[var(--bg)]">
          {/* FILTERS */}
          <div className="grid md:grid-cols-3 gap-6 mb-8">
            {/* Mapel */}
            <div>
              <p className="font-extrabold mb-2 text-sm text-[var(--ink)]">Mapel</p>
              <div className="flex flex-wrap gap-2">
                {['mtk', 'fis', 'ing'].map(m => (
                  <button
                    key={m}
                    onClick={() => setFilter({...filter, mapel: m})}
                    className={`rounded-full px-4 py-1.5 font-bold text-sm border-2 transition-colors ${filter.mapel === m ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'bg-[var(--card)] border-[var(--line)] text-[var(--ink)] hover:border-[var(--blue)]'}`}
                  >
                    {MAPEL_LABELS[m]}
                  </button>
                ))}
              </div>
            </div>
            {/* Jenjang */}
            <div>
              <p className="font-extrabold mb-2 text-sm text-[var(--ink)]">Jenjang</p>
              <div className="flex flex-wrap gap-2">
                {['sd', 'smp', 'sma'].map(j => (
                  <button
                    key={j}
                    onClick={() => setFilter({...filter, jenjang: j})}
                    className={`rounded-full px-4 py-1.5 font-bold text-sm border-2 transition-colors ${filter.jenjang === j ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'bg-[var(--card)] border-[var(--line)] text-[var(--ink)] hover:border-[var(--blue)]'}`}
                  >
                    {MAPEL_LABELS[j]}
                  </button>
                ))}
              </div>
            </div>
            {/* Budget */}
            <div>
              <p className="font-extrabold mb-2 text-sm text-[var(--ink)]">Budget per sesi</p>
              <div className="flex flex-wrap gap-2">
                {['100', '150', '200'].map(b => (
                  <button
                    key={b}
                    onClick={() => setFilter({...filter, budget: b})}
                    className={`rounded-full px-4 py-1.5 font-bold text-sm border-2 transition-colors ${filter.budget === b ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'bg-[var(--card)] border-[var(--line)] text-[var(--ink)] hover:border-[var(--blue)]'}`}
                  >
                    ≤ {b}rb
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* RESULT TEXT */}
          <p className="font-bold mb-5 text-[var(--ink)]">
            {filteredTutors.length > 0
              ? `${filteredTutors.length} tutor cocok`
              : 'Belum ada yang pas, coba naikkan budget'} untuk {MAPEL_LABELS[filter.mapel]} · {MAPEL_LABELS[filter.jenjang]} · ≤ {filter.budget}rb
          </p>

          {/* TUTOR CARDS */}
          {loading ? (
             <div className="flex justify-center py-10">
               <Loader2 className="animate-spin text-[var(--blue)]" size={32} />
             </div>
          ) : tutors.length === 0 ? (
            <div className="text-center py-10 text-[var(--mute)] font-semibold">
              Belum ada tutor unggulan yang ditambahkan.
            </div>
          ) : (
            <div className="grid md:grid-cols-3 gap-6 items-start">
              {tutors.map((t, i) => {
                const isMatch = filteredTutors.find(f => f.id === t.id);
                const marginTop = i === 1 ? 'md:mt-10' : i === 2 ? 'md:mt-20' : 'md:mt-0';

                return (
                  <article
                    key={t.id}
                    className={`bg-[var(--card)] rounded-3xl p-6 border-2 transition-all duration-300 ${marginTop} ${isMatch ? 'border-[var(--blue)] opacity-100 scale-100 shadow-[0_18px_0_-8px_var(--line),0_24px_40px_-18px_rgba(26,94,170,.35)] hover:-translate-y-1.5 hover:rotate-[-0.6deg]' : 'border-[var(--line)] opacity-35 scale-95'}`}
                  >
                    <div className="flex items-center gap-4">
                      <div className={`w-14 h-14 rounded-2xl grid place-items-center text-xl font-extrabold ${t.bg} ${t.text}`}>
                        {t.initials}
                      </div>
                      <div>
                        <h3 className="font-extrabold text-xl text-[var(--ink)]">{t.name}</h3>
                        <p className="text-sm text-[var(--mute)]">{t.campus}</p>
                      </div>
                    </div>
                    <span className={`inline-block mt-4 rounded-full px-3 py-1 text-xs font-extrabold ${isMatch ? 'bg-[var(--yel)] text-[var(--ink)]' : 'bg-[var(--soft)] text-[var(--ink)]'}`}>
                      {t.badge}
                    </span>
                    <p className="mt-3 text-[var(--mute)] text-sm leading-relaxed line-clamp-3">{t.desc}</p>
                    <div className="mt-5 flex items-end justify-between">
                      <p className="font-extrabold text-xl text-[var(--ink)]">
                        Rp{t.price}rb<span className="text-sm text-[var(--mute)] font-semibold">/sesi</span>
                      </p>
                      <span className="font-bold text-sm text-[var(--ink)] flex items-center gap-1">
                        <Star size={14} className="fill-[var(--yel)] text-[var(--yel)]" /> {t.rating}
                      </span>
                    </div>
                  </article>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}