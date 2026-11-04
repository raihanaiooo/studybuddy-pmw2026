import { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';

export function UniversityMarquee() {
  const [unis, setUnis] = useState<any[]>([]);

  useEffect(() => {
    const fetchUnis = async () => {
      const { data } = await supabase
        .from('universities')
        .select('*')
        .eq('is_active', true);
      if (data) setUnis(data);
    };
    fetchUnis();
  }, []);

  if (unis.length === 0) return null;

  const marqueeItems = [...unis, ...unis]; // Duplikasi agar loop mulus

  return (
    <section className="py-14 overflow-hidden border-y border-[var(--line)] bg-[var(--card)]">
      <p className="text-center font-bold text-[var(--mute)] mb-6 px-5">Tutor kami datang dari kampus-kampus ini</p>
      <div className="animate-marquee" aria-hidden="true">
        {marqueeItems.map((u, i) => (
          <div key={`${u.id}-${i}`} className="flex items-center gap-3 rounded-2xl border-2 border-[var(--line)] bg-[var(--bg)] px-4 py-3 shrink-0">
            {u.logo_url ? (
               <img src={u.logo_url} alt={u.name} className="w-11 h-11 object-contain rounded-xl bg-white p-1" />
            ) : (
              <span className={`w-11 h-11 rounded-xl grid place-items-center font-extrabold text-xs ${i % 3 === 0 ? 'bg-[var(--blue)] text-white' : i % 3 === 1 ? 'bg-[var(--bdark)] text-white' : 'bg-[var(--yel)] text-[var(--ink)]'}`}>
                {u.name.substring(0, 2).toUpperCase()}
              </span>
            )}
            <span className="font-bold text-sm whitespace-nowrap">{u.name}</span>
          </div>
        ))}
      </div>
    </section>
  );
}