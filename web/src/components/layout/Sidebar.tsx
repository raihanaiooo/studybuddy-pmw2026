import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard, ShoppingCart, GraduationCap, CalendarDays,
  FileText, Wallet, RefreshCw, AlertTriangle, Package, Ticket, Settings
} from 'lucide-react';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

const menuItems = [
  { path: '/dashboard', label: 'Dashboard', icon: <LayoutDashboard size={18} /> },
  { path: '/orders', label: 'Orderan Masuk', icon: <ShoppingCart size={18} /> },
  { path: '/tutors', label: 'Verifikasi Tutor', icon: <GraduationCap size={18} /> },
  { path: '/bookings', label: 'Bookings', icon: <CalendarDays size={18} /> },
  { path: '/content', label: 'Manajemen Konten', icon: <FileText size={18} /> },
  { path: '/payments', label: 'Transaksi', icon: <Wallet size={18} /> },
  { path: '/reschedules', label: 'Reschedule', icon: <RefreshCw size={18} /> },
  { path: '/complaints', label: 'Komplain', icon: <AlertTriangle size={18} /> },
  { path: '/payroll', label: 'Payroll', icon: <Wallet size={18} /> },
  { path: '/packages', label: 'Paket Belajar', icon: <Package size={18} /> },
  { path: '/tokens', label: 'Token Buddy', icon: <Ticket size={18} /> },
  { path: '/settings', label: 'Pengaturan', icon: <Settings size={18} /> },
];

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  return (
    <>
      {isOpen && <div className="fixed inset-0 bg-black/40 z-40 lg:hidden" onClick={onClose} />}

      <aside className={`fixed lg:static z-50 inset-y-0 left-0 w-64 shrink-0 bg-[var(--card)] border-r border-[var(--line)] flex flex-col transform transition-transform duration-200 ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>

        {/* Logo Area */}
        <div className="h-14 flex items-center gap-2.5 px-4 border-b border-[var(--line)]">
          <span className="w-8 h-8 rounded-lg bg-[var(--blue)] text-white grid place-items-center font-extrabold text-sm">SB</span>
          <div className="leading-tight">
            <p className="font-extrabold text-[var(--ink)]">Study Buddy</p>
            <p className="text-xs text-[var(--mute)]">Admin Panel</p>
          </div>
        </div>

        {/* Menu Area */}
        <nav className="p-3 space-y-1 overflow-y-auto flex-1">
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg font-semibold transition-colors ${
                  isActive
                    ? 'bg-[var(--hov)] text-[var(--blue)]'
                    : 'text-[var(--mute)] hover:bg-[var(--hov)] hover:text-[var(--ink)]'
                }`
              }
            >
              {item.icon}
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        {/* Footer Sidebar */}
        <div className="p-3 border-t border-[var(--line)] text-xs text-[var(--mute)]">
          Versi prototype 0.1
        </div>
      </aside>
    </>
  );
}