import { useAuth } from '../../hooks/useAuth';
import { LogOut } from 'lucide-react';

export function Header({ onMenuClick }: { onMenuClick: () => void }) {
  const { user, signOut } = useAuth();

  return (
    <header className="h-14 shrink-0 bg-[var(--card)] border-b border-[var(--line)] flex items-center gap-3 px-4 md:px-6">
      {/* Tombol Hamburger Mobile */}
      <button onClick={onMenuClick} className="btn !p-2 lg:hidden">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M4 6h16M4 12h16M4 18h16"/></svg>
      </button>

      <h1 className="font-extrabold text-lg text-[var(--ink)]">Admin Panel</h1>

      {/* User Area */}
      <div className="ml-auto flex items-center gap-3">
        <div className="hidden sm:flex items-center gap-2.5">
          <span className="w-8 h-8 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs">
            {user?.full_name?.[0]?.toUpperCase() || 'A'}
          </span>
          <div className="leading-tight">
            <p className="font-bold text-sm text-[var(--ink)]">{user?.full_name || 'Admin'}</p>
            <p className="text-xs text-[var(--mute)]">Admin</p>
          </div>
        </div>

        <button onClick={signOut} className="btn text-[var(--mute)]">
          <LogOut size={16} />
          <span className="hidden sm:inline">Logout</span>
        </button>
      </div>
    </header>
  );
}