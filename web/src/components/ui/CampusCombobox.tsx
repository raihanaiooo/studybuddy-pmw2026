import { useId, useMemo, useState } from 'react';
import { CAMPUS_SUGGESTIONS, filterCampuses } from '../../lib/campuses';

interface Props {
  id: string;
  value: string;
  onChange: (value: string) => void;
  /** Dipanggil saat pengguna selesai mengisi (pilih dari daftar atau pindah kolom). */
  onCommit?: (value: string) => void;
  inputClassName: string;
  invalid?: boolean;
  describedBy?: string;
}

/**
 * Kolom kampus dengan daftar saran bergaya aplikasi. Isian tetap bebas: yang diketik pelamar
 * adalah nilainya, daftar hanya membantu memilih.
 */
export function CampusCombobox({ id, value, onChange, onCommit, inputClassName, invalid, describedBy }: Props) {
  const listId = useId();
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(-1);
  const searching = value.trim() !== '';
  // Tanpa ketikan: 8 kampus pertama. Mengetik: semua yang cocok, daftar bisa digulir.
  const results = useMemo(() => filterCampuses(value, searching ? CAMPUS_SUGGESTIONS.length : 8), [value, searching]);

  function choose(campus: string) {
    onChange(campus);
    onCommit?.(campus);
    setOpen(false);
    setActive(-1);
  }

  function onKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setOpen(true);
      setActive((i) => (results.length === 0 ? -1 : (i + 1) % results.length));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setOpen(true);
      setActive((i) => (results.length === 0 ? -1 : (i <= 0 ? results.length - 1 : i - 1)));
    } else if (e.key === 'Enter' && open && active >= 0 && results[active]) {
      e.preventDefault();
      choose(results[active]);
    } else if (e.key === 'Escape' && open) {
      e.preventDefault();
      setOpen(false);
      setActive(-1);
    }
  }

  const showList = open;

  return (
    <div className="relative">
      <input
        id={id}
        role="combobox"
        aria-expanded={showList}
        aria-controls={listId}
        aria-autocomplete="list"
        aria-activedescendant={showList && active >= 0 ? `${listId}-${active}` : undefined}
        aria-invalid={invalid}
        aria-describedby={describedBy}
        autoComplete="off"
        className={inputClassName}
        value={value}
        placeholder="Institut Teknologi Bandung (ITB)"
        maxLength={100}
        onChange={(e) => {
          onChange(e.target.value);
          setOpen(true);
          setActive(-1);
        }}
        onFocus={() => setOpen(true)}
        onBlur={() => {
          setOpen(false);
          setActive(-1);
          onCommit?.(value);
        }}
        onKeyDown={onKeyDown}
      />
      {showList && (
        <ul
          id={listId}
          role="listbox"
          aria-label="Saran nama kampus"
          className="absolute left-0 right-0 z-20 mt-2 max-h-64 overflow-y-auto rounded-2xl border-2 border-[var(--line)] bg-[var(--card)] p-1.5 shadow-[0_8px_0_rgba(0,0,0,0.04)]"
        >
          {results.map((campus, i) => (
            <li
              key={campus}
              id={`${listId}-${i}`}
              role="option"
              aria-selected={i === active}
              // mouseDown (bukan click) supaya input tidak kehilangan fokus sebelum pilihan terbaca
              onMouseDown={(e) => {
                e.preventDefault();
                choose(campus);
              }}
              onMouseEnter={() => setActive(i)}
              className={`cursor-pointer rounded-xl px-3 py-2.5 text-sm font-semibold ${i === active ? 'bg-[var(--hov)] text-[var(--blue)]' : 'text-[var(--ink)]'}`}
            >
              {campus}
            </li>
          ))}
          {results.length > 0 && (
            <li role="presentation" className="sticky bottom-0 border-t border-[var(--line)] bg-[var(--card)] px-3 py-2 text-xs text-[var(--mute)]">
              {searching ? `${results.length} kampus cocok` : `Menampilkan 8 dari ${CAMPUS_SUGGESTIONS.length} kampus. Ketik untuk mencari.`}
            </li>
          )}
          {results.length === 0 && (
            <li role="presentation" className="px-3 py-2.5 text-sm text-[var(--mute)]">
              Tidak ada di daftar. Tulis nama kampusmu sendiri, tidak masalah.
            </li>
          )}
        </ul>
      )}
    </div>
  );
}
