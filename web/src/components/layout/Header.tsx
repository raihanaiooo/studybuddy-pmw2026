import { useAuth } from '../../hooks/useAuth';

interface HeaderProps {
  onMenuClick: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  const { user, signOut } = useAuth();

  return (
    <header className="h-[72px] bg-card border-b border-border flex items-center justify-between px-4 lg:px-6 shrink-0 z-30">
      {/* Hamburger mobile */}
      <button
        onClick={onMenuClick}
        className="lg:hidden w-10 h-10 rounded-xl hover:bg-background flex items-center justify-center text-xl transition-colors"
        aria-label="Menu"
      >
        ☰
      </button>

      <div className="hidden lg:block">
        <h2 className="text-[13.5px] text-text-secondary font-nunito">
          Selamat datang kembali 👋
        </h2>
      </div>

      {/* User */}
      <div className="flex items-center gap-2 lg:gap-3">
        <div className="hidden sm:block text-right mr-1">
          <p className="text-[13.5px] font-poppins font-semibold text-text-primary leading-tight">
            {user?.full_name ?? 'Admin'}
          </p>
          <p className="text-[11px] text-text-light font-nunito leading-tight">
            {user?.email}
          </p>
        </div>

        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-blue-dark to-primary-blue-light flex items-center justify-center text-white font-poppins font-bold text-sm shadow-sm shrink-0">
          {user?.full_name?.[0]?.toUpperCase() ?? 'A'}
        </div>

        <button
          onClick={signOut}
          className="hidden sm:flex items-center gap-2 h-10 px-3.5 rounded-xl text-[13px] font-nunito font-semibold text-primary-red hover:bg-primary-red-subtle transition-colors"
        >
          <span>🚪</span>
          <span>Keluar</span>
        </button>

        <button
          onClick={signOut}
          className="sm:hidden w-10 h-10 rounded-xl hover:bg-primary-red-subtle flex items-center justify-center transition-colors"
          aria-label="Logout"
        >
          🚪
        </button>
      </div>
    </header>
  );
}