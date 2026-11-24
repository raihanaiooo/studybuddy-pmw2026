/** Fungsi tampilan untuk halaman Order (tanpa React agar bisa diuji). */

export function formatRupiah(value: number | string | null | undefined): string {
  const n = Number(value ?? 0);
  const whole = Number.isInteger(n);
  return `Rp${n.toLocaleString('id-ID', { minimumFractionDigits: whole ? 0 : 2, maximumFractionDigits: 2 })}`;
}

export function orderStatusLabel(status: string): string {
  return status === 'progress' ? 'Berjalan' : status === 'done' ? 'Selesai' : status === 'batal' ? 'Batal' : status;
}

export function sessionStatusLabel(status: string): string {
  return status === 'terjadwal' ? 'Terjadwal' : status === 'selesai' ? 'Selesai' : status === 'batal' ? 'Batal' : status;
}

export function paymentLabel(status: string | null | undefined): string {
  if (status === 'lunas') return 'Lunas';
  if (status === 'sebagian') return 'Sebagian';
  if (status === 'belum') return 'Belum bayar';
  return '-';
}

export interface BuddyGroup {
  key: string;
  name: string;
  orders: number;
  running: number;
  total: number;
}

/** Kelompokkan order per buddy (nama dianggap sama bila hanya beda huruf besar kecil atau spasi di tepi). */
export function groupByBuddy(rows: ReadonlyArray<{ buddy_name: string; total_price: number | string; status: string }>): BuddyGroup[] {
  const map = new Map<string, BuddyGroup>();
  for (const r of rows) {
    const name = (r.buddy_name ?? '').trim();
    const key = name.toLowerCase().replace(/\s+/g, ' ');
    const g = map.get(key) ?? { key, name, orders: 0, running: 0, total: 0 };
    g.orders += 1;
    if (r.status === 'progress') g.running += 1;
    g.total += Number(r.total_price ?? 0);
    map.set(key, g);
  }
  return [...map.values()];
}
