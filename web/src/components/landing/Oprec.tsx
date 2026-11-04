import { ArrowRight, CheckCircle2 } from 'lucide-react';

export function Oprec({ previewData }: { previewData?: any }) {
  const data = previewData || {
    title: 'Mahasiswa? Jadi Buddy, dibayar buat berbagi ilmu.',
    description: 'Open recruitment tutor batch baru dibuka. Atur jadwal sendiri, tentukan mapel, dan dapat murid yang sudah dicocokkan sistem.',
    benefits: ['Jadwal fleksibel', 'Pembayaran tiap pekan', 'Pelatihan mengajar', 'Sertifikat pengalaman'],
    cta_label: 'Daftar jadi tutor',
    cta_link: '#order',
    is_active: true
  };

  if (!data.is_active) return null; // Sembunyikan section kalau dimatikan

  return (
    <section id="oprec" className="max-w-6xl mx-auto px-5 py-20 md:py-28">
      <div className="relative rounded-[2.2rem] bg-[var(--yel)] text-[var(--ink)] p-8 md:p-14 overflow-hidden shadow-[0_10px_0_#B87A00]">
        <div className="absolute -right-10 -top-10 w-56 h-56 rounded-full bg-[var(--blue)] opacity-90" />
        <div className="absolute right-24 bottom-[-60px] w-40 h-40 rounded-full bg-[#1A1F3C]" />

        <div className="relative max-w-2xl">
          <h2 className="text-4xl md:text-6xl font-extrabold leading-[1.02]">{data.title}</h2>
          <p className="mt-5 text-lg font-medium max-w-lg">{data.description}</p>

          <ul className="mt-6 grid sm:grid-cols-2 gap-x-6 gap-y-2 font-bold text-sm max-w-lg">
            {data.benefits.map((b: string, i: number) => (
              <li key={i} className="flex items-center gap-2"><CheckCircle2 size={18} /> {b}</li>
            ))}
          </ul>

          <a
            href={data.cta_link}
            target={data.cta_link.startsWith('http') ? '_blank' : '_self'}
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center gap-2 mt-8 font-extrabold rounded-2xl py-3 px-6 bg-[#1A1F3C] text-white shadow-[0_5px_0_#000] hover:-translate-y-0.5 hover:shadow-[0_7px_0_#000] active:translate-y-1 active:shadow-none transition-all"
          >
            {data.cta_label} <ArrowRight size={18} />
          </a>
        </div>
      </div>
    </section>
  );
}