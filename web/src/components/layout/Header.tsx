import { useAuth } from '../../hooks/useAuth';

interface HeaderProps {
  onMenuClick: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  const { user, signOut } = useAuth();

  return (
    <header className="bg-white border-b border-[#E5E7EB] px-4 lg:px-6 py-3 flex items-center justify-between sticky top-0 z-30">
      {/* Hamburger untuk mobile */}
      <button
        onClick={onMenuClick}
        className="lg:hidden w-10 h-10 rounded-lg hover:bg-[#F5F6FA] flex items-center justify-center text-xl"
        aria-label="Menu"
      >
        ☰
      </button>

      <div className="hidden lg:block">
        <h2 className="text-sm text-[#6B7280]">
          Selamat datang kembali,
        </h2>
      </div>

      {/* User info */}
      <div className="flex items-center gap-3">
        <div className="hidden sm:block text-right">
          <p className="text-sm font-semibold text-[#1A1F3C]">
            {user?.full_name ?? 'Admin'}
          </p>
          <p className="text-xs text-[#6B7280]">{user?.email}</p>
        </div>

        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] flex items-center justify-center text-white font-bold">
          {user?.full_name?.[0]?.toUpperCase() ?? 'A'}
        </div>

        <button
          onClick={signOut}
          className="hidden sm:flex px-3 py-2 text-sm text-[#E53935] hover:bg-[#E53935]/10 rounded-lg font-medium transition-colors"
        >
          Keluar
        </button>

        <button
          onClick={signOut}
          className="sm:hidden w-10 h-10 rounded-lg hover:bg-[#E53935]/10 flex items-center justify-center"
          aria-label="Logout"
        >
          🚪
        </button>
      </div>
    </header>
  );
}