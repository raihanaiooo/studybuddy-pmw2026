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
  { path: '/packages', label: 'Paket & Token', icon: '🎟️' },
];

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  return (
    <>
      {/* Overlay untuk mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/40 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`
          fixed lg:static top-0 left-0 h-full w-64 bg-white border-r border-[#E5E7EB] z-50
          transform transition-transform duration-200 ease-in-out
          ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}
      >
        {/* Logo */}
        <div className="p-6 border-b border-[#E5E7EB]">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#1A5EAA] to-[#6BB5FF] flex items-center justify-center text-white text-xl">
              📚
            </div>
            <div>
              <h1 className="font-bold text-[#1A1F3C] leading-tight">
                Study Buddy
              </h1>
              <p className="text-xs text-[#6B7280]">Admin Panel</p>
            </div>
          </div>
        </div>

        {/* Menu */}
        <nav className="p-4 space-y-1 overflow-y-auto h-[calc(100%-88px)]">
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={onClose}
              className={({ isActive }) =>
                `
                flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium
                transition-colors duration-150
                ${
                  isActive
                    ? 'bg-[#1A5EAA] text-white'
                    : 'text-[#6B7280] hover:bg-[#F5F6FA] hover:text-[#1A1F3C]'
                }
              `
              }
            >
              <span className="text-lg">{item.icon}</span>
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
      </aside>
    </>
  );
}