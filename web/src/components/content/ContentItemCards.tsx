import { Pencil, Trash2 } from 'lucide-react';

interface SwitchProps {
  on: boolean;
  label: string;
  onChange: (next: boolean) => void;
}

/** Sakelar tayang/sembunyi: satu klik langsung tersimpan. */
export function VisibilitySwitch({ on, label, onChange }: SwitchProps) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      aria-label={label}
      onClick={() => onChange(!on)}
      className="switch"
    />
  );
}

function initials(name: string) {
  if (!name) return '?';
  return name.split(' ').map((w) => w[0]).slice(0, 2).join('').toUpperCase();
}

interface CardProps {
  item: any;
  visible: boolean;
  onToggle: (next: boolean) => void;
  onEdit: () => void;
  onDelete: () => void;
}

function Footer({ visible, name, onToggle, onEdit, onDelete }: { visible: boolean; name: string; onToggle: (n: boolean) => void; onEdit: () => void; onDelete: () => void }) {
  return (
    <div className="mt-auto pt-3 border-t border-[var(--line)] flex items-center gap-3">
      <VisibilitySwitch on={visible} label={`Tampilkan ${name} di landing page`} onChange={onToggle} />
      <span className={`text-xs font-semibold ${visible ? 'text-[#166534]' : 'text-[var(--mute)]'}`}>
        {visible ? 'Tampil' : 'Disembunyikan'}
      </span>
      <button
        type="button"
        onClick={onEdit}
        aria-label={`Edit ${name}`}
        title="Edit"
        className="ml-auto p-1.5 rounded-lg text-[var(--mute)] hover:text-[var(--blue)] hover:bg-[var(--soft)] transition-colors"
      >
        <Pencil size={16} />
      </button>
      <button
        type="button"
        onClick={onDelete}
        aria-label={`Hapus ${name}`}
        title="Hapus"
        className="p-1.5 rounded-lg text-[var(--mute)] hover:text-red-600 hover:bg-red-50 transition-colors"
      >
        <Trash2 size={16} />
      </button>
    </div>
  );
}

export function TestimonialCard({ item, visible, onToggle, onEdit, onDelete }: CardProps) {
  return (
    <article className={`card p-4 flex flex-col gap-3 transition-opacity ${visible ? '' : 'opacity-60'}`}>
      <div className="flex items-center gap-3">
        <span className="w-9 h-9 rounded-full bg-[var(--blue)] text-white grid place-items-center font-bold text-xs shrink-0">
          {initials(item.name)}
        </span>
        <div className="min-w-0">
          <h3 className="font-bold text-[var(--ink)] truncate leading-tight">{item.name}</h3>
          <p className="text-[var(--mute)] text-xs truncate">{item.role}</p>
        </div>
      </div>
      <p className="text-sm text-[var(--ink)] leading-relaxed line-clamp-4">“{item.content}”</p>
      <Footer visible={visible} name={item.name} onToggle={onToggle} onEdit={onEdit} onDelete={onDelete} />
    </article>
  );
}

export function UniversityCard({ item, visible, onToggle, onEdit, onDelete }: CardProps) {
  return (
    <article className={`card p-3 flex flex-col gap-3 transition-opacity ${visible ? '' : 'opacity-60'}`}>
      <div className="flex items-center gap-3">
        {item.logo_url ? (
          <img src={item.logo_url} alt="" className="w-9 h-9 rounded object-contain shrink-0" />
        ) : (
          <span className="w-9 h-9 rounded-lg bg-[var(--soft)] border border-[var(--line)] text-[var(--blue)] grid place-items-center font-bold text-xs shrink-0">
            {initials(item.name)}
          </span>
        )}
        <h3 className="font-bold text-[var(--ink)] truncate">{item.name}</h3>
      </div>
      <Footer visible={visible} name={item.name} onToggle={onToggle} onEdit={onEdit} onDelete={onDelete} />
    </article>
  );
}
