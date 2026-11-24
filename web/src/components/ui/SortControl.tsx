import { ArrowDown, ArrowUp } from 'lucide-react';
import type { SortDir } from '../../lib/sortList';

interface Props {
  options: ReadonlyArray<{ key: string; label: string }>;
  sortKey: string;
  dir: SortDir;
  onChange: (key: string, dir: SortDir) => void;
}

/** Pilihan urutan + tombol naik/turun, dipakai di semua daftar. */
export function SortControl({ options, sortKey, dir, onChange }: Props) {
  const asc = dir === 'asc';
  return (
    <div className="flex items-center gap-1.5 shrink-0">
      <label className="sr-only" htmlFor="sort-key">Urutkan berdasarkan</label>
      <select
        id="sort-key"
        value={sortKey}
        onChange={(e) => onChange(e.target.value, dir)}
        className="inp !w-auto !py-2 text-sm font-semibold"
      >
        {options.map((o) => (
          <option key={o.key} value={o.key}>{o.label}</option>
        ))}
      </select>
      <button
        type="button"
        onClick={() => onChange(sortKey, asc ? 'desc' : 'asc')}
        className="btn !px-2.5 !py-2"
        aria-label={asc ? 'Urut naik (A ke Z, lama ke baru). Klik untuk membalik' : 'Urut turun (Z ke A, baru ke lama). Klik untuk membalik'}
        title={asc ? 'Naik' : 'Turun'}
      >
        {asc ? <ArrowUp size={16} /> : <ArrowDown size={16} />}
      </button>
    </div>
  );
}
