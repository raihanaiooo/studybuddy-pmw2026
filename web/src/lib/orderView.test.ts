import { describe, expect, it } from 'vitest';
import { formatRupiah, groupByBuddy, orderStatusLabel, paymentLabel, sessionStatusLabel } from './orderView';

describe('orderView', () => {
  it('formatRupiah: titik ribuan, sen hanya bila ada', () => {
    expect(formatRupiah(6460000)).toBe('Rp6.460.000');
    expect(formatRupiah(95333.33)).toBe('Rp95.333,33');
    expect(formatRupiah('42000.00')).toBe('Rp42.000');
    expect(formatRupiah(null)).toBe('Rp0');
  });

  it('label status order, sesi, dan pembayaran', () => {
    expect(orderStatusLabel('progress')).toBe('Berjalan');
    expect(orderStatusLabel('done')).toBe('Selesai');
    expect(orderStatusLabel('batal')).toBe('Batal');
    expect(sessionStatusLabel('terjadwal')).toBe('Terjadwal');
    expect(sessionStatusLabel('selesai')).toBe('Selesai');
    expect(paymentLabel('lunas')).toBe('Lunas');
    expect(paymentLabel('sebagian')).toBe('Sebagian');
    expect(paymentLabel('belum')).toBe('Belum bayar');
    expect(paymentLabel(undefined)).toBe('-');
  });

  it('groupByBuddy: satu nama = satu buddy walau beda huruf besar/spasi; total dan jumlah dijumlahkan', () => {
    const rows = [
      { buddy_name: 'Rifqah Putri Zafira', total_price: 38000, status: 'done' },
      { buddy_name: ' rifqah putri zafira ', total_price: 322500, status: 'done' },
      { buddy_name: 'Elsya', total_price: 450000, status: 'progress' },
    ];
    const g = groupByBuddy(rows);
    expect(g).toHaveLength(2);
    const r = g.find((x) => x.key === 'rifqah putri zafira')!;
    expect(r.orders).toBe(2);
    expect(r.total).toBe(360500);
    expect(r.name).toBe('Rifqah Putri Zafira');
    expect(g.find((x) => x.key === 'elsya')!.running).toBe(1);
  });
});
