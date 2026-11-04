import { useEffect, useState } from 'react';
import { Star } from 'lucide-react';
import { supabase } from '../../lib/supabase';

export function Testimonials() {
  const [testimonials, setTestimonials] = useState<any[]>([]);

  useEffect(() => {
    const fetchTestimonials = async () => {
      const { data } = await supabase
        .from('testimonials')
        .select('*')
        .eq('is_published', true)
        .limit(3); // Ambil maksimal 3 untuk landing page
      if (data) setTestimonials(data);
    };
    fetchTestimonials();
  }, []);

  if (testimonials.length === 0) return null; // Sembunyikan jika kosong

  return (
    <section id="testimoni" className="pb-20 md:pb-28">
      <div className="max-w-6xl mx-auto px-5">
        <h2 className="text-4xl md:text-6xl font-extrabold leading-[1.02] max-w-2xl text-[var(--ink)]">Kata para Buddy yang sudah mencoba.</h2>

        <div className="mt-12 grid md:grid-cols-3 gap-6 items-start">
          {testimonials.map((t, index) => {
            // Bikin variasi warna card: card ke-2 dibikin biru
            const isBlue = index === 1;
            return (
              <figure
                key={t.id}
                className={`lift rounded-3xl p-7 border-2 ${isBlue ? 'bg-[var(--blue)] text-white border-none md:mt-10 shadow-[0_8px_0_var(--bdark)]' : 'bg-[var(--card)] border-[var(--line)] md:mt-0'}`}
              >
                <div className="flex text-[var(--yel)] gap-1">
                  {[1,2,3,4,5].map(i => <Star key={i} size={18} fill="currentColor" />)}
                </div>
                <blockquote className="mt-3 font-semibold leading-relaxed">"{t.content}"</blockquote>
                <figcaption className="mt-6 flex items-center gap-3">
                  <span className={`w-10 h-10 rounded-full grid place-items-center font-extrabold ${isBlue ? 'bg-white text-[var(--bdark)]' : 'bg-[var(--blue)] text-white'}`}>
                    {t.name.substring(0, 2).toUpperCase()}
                  </span>
                  <span className="text-sm">
                    <b className="block">{t.name}</b>
                    <span className={isBlue ? 'opacity-80' : 'text-[var(--mute)]'}>{t.role}</span>
                  </span>
                </figcaption>
              </figure>
            );
          })}
        </div>
      </div>
    </section>
  );
}