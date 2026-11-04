export function Footer() {
  return (
    <footer className="bg-[#1A1F3C] text-[#F0F4FF]">
      <div className="max-w-6xl mx-auto px-5 py-14 grid md:grid-cols-12 gap-10">
        <div className="md:col-span-6">
          <p className="text-3xl font-extrabold">Study<span className="text-[var(--yel)]">Buddy</span></p>
          <p className="mt-3 max-w-xs text-[#9AA3BD]">Les privat yang cocok, dari tutor kampus terbaik.</p>
        </div>
        <div className="md:col-span-3 font-semibold space-y-2">
          <a className="block hover:text-[var(--yel)] transition" href="#tutor">Cari Tutor</a>
          <a className="block transition hover:opacity-70" href="#oprec">Info Oprec</a>
          <a className="block transition hover:opacity-70" href="#testimoni">Testimoni</a>
        </div>
        <div className="md:col-span-3 font-semibold space-y-2 text-[#9AA3BD]">
          <p>admin@studybuddy.id</p><p>WhatsApp: 0812-0000-0000</p><p>Senin–Sabtu, 08.00–20.00</p>
        </div>
      </div>
      <p className="text-center text-sm pb-8 text-[#9AA3BD]">© 2026 Study Buddy. Prototype.</p>
    </footer>
  );
}