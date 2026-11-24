import { NavLink } from 'react-router-dom';
import { LayoutDashboard, ShoppingCart, UserPlus, GraduationCap, FileText, Settings, ClipboardCheck } from 'lucide-react';
import type { ReactNode } from 'react';
import { NAV_SECTIONS, type NavIconKey } from '../../lib/navigation';

interface SidebarProps {
  isOpen: boolean;
  collapsed: boolean;
  onClose: () => void;
}

const ICONS: Record<NavIconKey, ReactNode> = {
  dashboard: <LayoutDashboard size={18} />,
  orders: <ShoppingCart size={18} />,
  leads: <UserPlus size={18} />,
  tutors: <GraduationCap size={18} />,
  content: <FileText size={18} />,
  diagnostics: <ClipboardCheck size={18} />,
  settings: <Settings size={18} />,
};

export function Sidebar({ isOpen, collapsed, onClose }: SidebarProps) {
  return (
    <>
      {isOpen && <div className="fixed inset-0 bg-black/40 z-40 lg:hidden" onClick={onClose} />}

      <aside className={`fixed lg:static z-50 inset-y-0 left-0 w-64 shrink-0 bg-[var(--card)] border-r border-[var(--line)] flex flex-col transform transition-transform duration-200 ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'} ${collapsed ? 'lg:hidden' : ''}`}>

        {/* Logo Area */}
        <div className="h-14 flex items-center gap-2.5 px-4 border-b border-[var(--line)]">
          <span className="w-8 h-8 rounded-lg bg-[var(--blue)] text-white grid place-items-center font-extrabold text-sm">SB</span>
          <div className="leading-tight">
            <p className="font-extrabold text-[var(--ink)]">Study Buddy</p>
            <p className="text-xs text-[var(--mute)]">Admin Panel</p>
          </div>
        </div>

        {/* Menu Area */}
        <nav className="p-3 space-y-4 overflow-y-auto flex-1" aria-label="Menu utama">
          {NAV_SECTIONS.map((section) => (
            <div key={section.heading ?? 'utama'} className="space-y-1">
              {section.heading && (
                <p className="px-3 pb-1 text-[11px] font-bold uppercase tracking-wider text-[var(--mute)]">
                  {section.heading}
                </p>
              )}
              {section.items.map((item) => (
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
                  {ICONS[item.icon]}
                  <span>{item.label}</span>
                </NavLink>
              ))}
            </div>
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