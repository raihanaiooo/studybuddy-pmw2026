export type SortDir = 'asc' | 'desc';

const collator = new Intl.Collator('id', { sensitivity: 'base', numeric: true });

/** Urutkan salinan daftar. Nilai kosong selalu di akhir; teks tidak peduli huruf besar kecil dan angka di dalam teks dibaca sebagai angka. */
export function sortItems<T>(items: readonly T[], get: (item: T) => string | number | null | undefined, dir: SortDir): T[] {
  const sign = dir === 'asc' ? 1 : -1;
  return [...items].sort((a, b) => {
    const x = get(a);
    const y = get(b);
    const xe = x === null || x === undefined || x === '';
    const ye = y === null || y === undefined || y === '';
    if (xe || ye) return xe === ye ? 0 : xe ? 1 : -1;
    if (typeof x === 'number' && typeof y === 'number') return (x - y) * sign;
    return collator.compare(String(x), String(y)) * sign;
  });
}
