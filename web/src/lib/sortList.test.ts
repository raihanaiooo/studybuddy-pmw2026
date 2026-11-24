import { describe, expect, it } from 'vitest';
import { sortItems } from './sortList';

describe('sortItems', () => {
  const rows = [{ n: 'budi', v: 3 }, { n: 'Ani', v: null }, { n: 'cici', v: 1 }, { n: 'Dedi', v: 2 }];

  it('teks: tanpa membedakan huruf besar kecil, naik dan turun', () => {
    expect(sortItems(rows, (r) => r.n, 'asc').map((r) => r.n)).toEqual(['Ani', 'budi', 'cici', 'Dedi']);
    expect(sortItems(rows, (r) => r.n, 'desc').map((r) => r.n)).toEqual(['Dedi', 'cici', 'budi', 'Ani']);
  });

  it('angka: nilai kosong selalu di akhir, apa pun arahnya', () => {
    expect(sortItems(rows, (r) => r.v, 'asc').map((r) => r.v)).toEqual([1, 2, 3, null]);
    expect(sortItems(rows, (r) => r.v, 'desc').map((r) => r.v)).toEqual([3, 2, 1, null]);
  });

  it('angka di dalam teks diurutkan sebagai angka (FO9 sebelum FO10)', () => {
    const fo = [{ n: 'FO10' }, { n: 'FO9' }, { n: 'FO100' }];
    expect(sortItems(fo, (r) => r.n, 'asc').map((r) => r.n)).toEqual(['FO9', 'FO10', 'FO100']);
  });

  it('tidak mengubah array asli', () => {
    const copy = [...rows];
    sortItems(rows, (r) => r.n, 'desc');
    expect(rows).toEqual(copy);
  });
});
