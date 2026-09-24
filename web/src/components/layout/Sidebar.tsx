import { NavLink } from 'react-router-dom';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

const menuItems = [
  { path: '/dashboard', label: 'Dashboard', icon: '📊' },
  { path: '/tutors', label: 'Verifikasi Tutor', icon: '👨‍🏫' },
  { path: '/bookings', label: 'Bookings', icon: '📅' },
  { path: '/payments', label: 'Transaksi', icon: '💰' },
  { path: '/reschedules', label: 'Reschedule', icon: '🔄' },
  { path: '/complaints', label: 'Komplain', icon: '⚠️' },
  { path: '/payroll', label: 'Payroll', icon: '📄' },
  { path: '/packages', label: 'Paket Belajar', icon: '📦' },
  { path: '/tokens', label: 'Token Buddy', icon: '🎟️' },
];

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  return (
    <>
      {/* Overlay mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/40 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`
          fixed lg:static top-0 left-0 h-full w-[260px] bg-card border-r border-border z-50
          transform transition-transform duration-200 ease-out
          flex flex-col
          ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}
      >
        {/* Logo */}
        <div className="px-5 h-[72px] flex items-center gap-3 border-b border-border shrink-0">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-blue-dark via-primary-blue to-primary-blue-light flex items-center justify-center text-white text-xl shadow-md shrink-0">
            📚
          </div>
          <div className="min-w-0">
            <h1 className="font-poppins font-bold text-[15px] text-text-primary leading-tight">
              Study Buddy
            </h1>
            <p className="text-[11px] text-text-light font-medium leading-tight">
              Admin Panel
            </p>
          </div>
        </div>

        {/* Menu */}
        <nav className="flex-1 overflow-y-auto p-3 space-y-0.5">
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={onClose}
              className={({ isActive }) =>
                `
                  flex items-center gap-3 h-11 px-3 rounded-xl text-[13.5px] font-nunito
                  transition-all duration-150
                  ${
                    isActive
                      ? 'bg-primary-blue text-white font-semibold shadow-sm'
                      : 'text-text-secondary font-medium hover:bg-background hover:text-text-primary'
                  }
                `
              }
            >
              <span className="text-[17px] leading-none shrink-0">{item.icon}</span>
              <span className="truncate">{item.label}</span>
            </NavLink>
          ))}
        </nav>

        {/* Footer */}
        <div className="p-3 border-t border-border shrink-0">
          <p className="text-[11px] text-text-light text-center font-nunito">
            v1.0.0 · Study Buddy © 2026
          </p>
        </div>
      </aside>
    </>
  );
}