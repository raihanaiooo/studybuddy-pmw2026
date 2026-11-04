import { ArrowRight } from 'lucide-react';

export function Hero({ previewData }: { previewData?: any }) {
  // Ambil data dari props (preview), kalau kosong pakai default
  const data = previewData || {
    headline: 'Belajar sama kakak kampus yang benar-benar paham.',
    subheadline: 'Pilih tutor privat dari UI, ITB, UGM dan kampus top lainnya. Cocok dengan mapel, jenjang, dan budget kamu — bukan sekadar yang kosong jadwalnya.',
    sticker_1_text: '🎯 Cocok 98%',
    sticker_2_text: 'Trial dulu, gratis!',
    hero_image_url: ''
  };

  return (
    <section className="relative overflow-hidden">
      <div className="max-w-6xl mx-auto px-5 pt-14 pb-24 md:pt-20 md:pb-32 grid md:grid-cols-12 gap-6 items-start">
        <div className="md:col-span-8 relative z-10">
          <p className="inline-flex items-center gap-2 bg-[var(--card)] border-2 border-[var(--line)] rounded-full pl-2 pr-4 py-1 font-bold text-sm mb-7 text-[var(--ink)]">
            <span className="w-6 h-6 rounded-full bg-[var(--yel)] grid place-items-center text-xs text-[var(--ink)]">★</span>
            1.200+ siswa sudah punya Buddy belajar
          </p>

          <h1 className="font-extrabold leading-[.95] text-[3.1rem] sm:text-7xl lg:text-[6.2rem] text-[var(--ink)]">
            {data.headline}
          </h1>

          <p className="mt-9 text-lg text-[var(--mute)] max-w-md leading-relaxed">
            {data.subheadline}
          </p>

          <div className="mt-9 flex flex-wrap items-center gap-5">
            <a href="#order" className="inline-flex items-center justify-center gap-2 font-extrabold rounded-2xl py-3 px-6 text-lg bg-[var(--blue)] text-white shadow-[0_5px_0_var(--bdark)] hover:-translate-y-0.5 hover:shadow-[0_7px_0_var(--bdark)] active:translate-y-1 active:shadow-none transition-all">
              Order les privat sekarang <ArrowRight size={20} />
            </a>
            <a href="#tutor" className="font-bold underline underline-offset-4 decoration-2 hover:decoration-[var(--yel)] text-[var(--bdark)]">
              Lihat rekomendasi tutor
            </a>
          </div>
        </div>

        {/* Bagian Mockup HP / Gambar */}
        <div className="md:col-span-4 relative flex justify-center md:justify-end md:mt-16 md:-ml-16 mt-10">
          <div className="relative rotate-3 w-[250px]">
            <div className="animate-float" style={{ '--r': '3deg' } as React.CSSProperties}>
              {data.hero_image_url ? (
                // KALAU ADA GAMBAR DARI CMS, TAMPILKAN GAMBAR
                <img src={data.hero_image_url} alt="Hero" className="rounded-[2.4rem] shadow-2xl object-cover w-full h-auto" />
              ) : (
                // KALAU KOSONG, TAMPILKAN MOCKUP HP BAWAAN
                <div className="rounded-[2.4rem] bg-[var(--ink)] p-2.5 shadow-[0_40px_60px_-25px_rgba(26,94,170,.55)]">
                  <div className="rounded-[1.9rem] overflow-hidden bg-[var(--bg)]">
                    <div className="bg-[var(--blue)] text-white px-4 pt-6 pb-4">
                      <p className="text-xs font-semibold opacity-80">Halo, Rani 👋</p>
                      <p className="font-extrabold text-lg leading-tight">Cari Buddy belajar?</p>
                    </div>
                    <div className="p-3 space-y-2.5">
                      <div className="flex gap-1.5 text-[11px] font-bold text-[var(--ink)]">
                        <span className="bg-[var(--yel)] rounded-full px-2.5 py-1">Matematika</span>
                        <span className="bg-[var(--card)] rounded-full px-2.5 py-1">SMA</span>
                        <span className="bg-[var(--card)] rounded-full px-2.5 py-1">≤ 150rb</span>
                      </div>
                      <div className="bg-[var(--card)] rounded-2xl p-3 flex gap-3 items-center border-2 border-[var(--blue)]">
                        <div className="w-10 h-10 rounded-full bg-[var(--blue)] text-white grid place-items-center font-extrabold shrink-0">AR</div>
                        <div className="min-w-0"><p className="font-extrabold text-sm text-[var(--ink)]">Alya R.</p><p className="text-[11px] text-[var(--mute)] leading-tight">ITB · Teknik Fisika</p></div>
                        <span className="ml-auto text-[10px] font-extrabold bg-[var(--yel)] text-[var(--ink)] rounded-full px-2 py-0.5 whitespace-nowrap">98%</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Stiker Melayang */}
            <div className="absolute -left-6 md:-left-12 top-24 z-10" style={{ transform: 'rotate(-4deg)' }}>
              <div className="animate-float" style={{ '--r': '-4deg', animationDelay: '-2s' } as React.CSSProperties}>
                <div className="bg-[var(--card)] border-2 border-[var(--line)] rounded-2xl px-3 py-2 font-extrabold text-sm shadow-lg text-[var(--ink)] whitespace-nowrap">
                  {data.sticker_1_text}
                </div>
              </div>
            </div>

            <div className="absolute -right-4 md:-right-8 bottom-10 z-10" style={{ transform: 'rotate(5deg)' }}>
              <div className="animate-float" style={{ '--r': '5deg', animationDelay: '-1s' } as React.CSSProperties}>
                <div className="bg-[var(--yel)] text-[var(--ink)] rounded-2xl px-3 py-2 font-extrabold text-sm shadow-[0_4px_0_#B87A00] whitespace-nowrap">
                  {data.sticker_2_text}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}