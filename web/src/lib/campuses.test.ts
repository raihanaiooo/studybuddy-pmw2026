import { describe, expect, it } from 'vitest';
import { CAMPUS_SUGGESTIONS, filterCampuses } from './campuses';

describe('filterCampuses', () => {
  it('tanpa ketikan menampilkan beberapa kampus pertama sesuai batas', () => {
    expect(filterCampuses('', 5)).toEqual(CAMPUS_SUGGESTIONS.slice(0, 5));
    expect(filterCampuses('   ', 3)).toEqual(CAMPUS_SUGGESTIONS.slice(0, 3));
  });

  it('mencocokkan sebagian nama tanpa peduli huruf besar-kecil', () => {
    const hasil = filterCampuses('gadjah');
    expect(hasil).toEqual(['Universitas Gadjah Mada (UGM)']);
  });

  it('mencocokkan singkatan di dalam kurung', () => {
    expect(filterCampuses('itb')).toContain('Institut Teknologi Bandung (ITB)');
    expect(filterCampuses('UGM')[0]).toBe('Universitas Gadjah Mada (UGM)');
  });

  it('nama yang diawali ketikan didahulukan dari yang hanya memuatnya', () => {
    const hasil = filterCampuses('institut');
    expect(hasil[0].toLowerCase().startsWith('institut')).toBe(true);
    const pertamaTidakDiawali = hasil.findIndex((c) => !c.toLowerCase().startsWith('institut'));
    const terakhirDiawali = hasil.map((c) => c.toLowerCase().startsWith('institut')).lastIndexOf(true);
    if (pertamaTidakDiawali !== -1) expect(terakhirDiawali).toBeLessThan(pertamaTidakDiawali);
  });

  it('menghormati batas jumlah hasil dan mengembalikan kosong bila tak ada yang cocok', () => {
    expect(filterCampuses('universitas', 4)).toHaveLength(4);
    expect(filterCampuses('kampus yang tidak ada')).toEqual([]);
  });
});
