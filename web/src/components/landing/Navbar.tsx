import { Link } from 'react-router-dom';

export function Navbar() {
  return (
    <header className="sticky top-0 z-40 border-b border-[var(--line)] bg-[var(--bg)]/90 backdrop-blur-md">
      <nav className="max-w-6xl mx-auto px-5 h-16 flex items-center justify-between">
        <Link to="/" className="text-2xl font-extrabold tracking-tight flex items-center gap-2 text-[var(--ink)]">
          <span className="grid place-items-center w-9 h-9 rounded-xl bg-[var(--blue)] text-white text-lg -rotate-6">S</span>
          Study<span className="text-[var(--blue)]">Buddy</span>
        </Link>
        <div className="hidden md:flex items-center gap-8 font-semibold text-[var(--mute)]">
          <a className="hover:text-[var(--ink)] transition" href="#tutor">Cari Tutor</a>
          <a className="hover:text-[var(--ink)] transition" href="#oprec">Info Oprec</a>
          <a className="hover:text-[var(--ink)] transition" href="#testimoni">Testimoni</a>
        </div>
        {/* Gunakan style manual, bukan .btn */}
        <a
          href="#order"
          className="inline-flex items-center justify-center font-extrabold rounded-2xl py-2 px-4 text-sm bg-[var(--yel)] text-[var(--ink)] shadow-[0_4px_0_#B87A00] hover:-translate-y-0.5 hover:shadow-[0_6px_0_#B87A00] active:translate-y-1 active:shadow-none transition-all"
        >
          Order Sekarang
        </a>
      </nav>
    </header>
  );
}