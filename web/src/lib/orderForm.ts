import { normalizeWhatsapp } from './tutorApplication';

export interface OrderInput {
  nama: string;
  wa: string;
  mapel: string;
  jenjang: string;
  attemptId?: string;
  packageId?: string;
  tutor?: string;
}

export type OrderErrors = Partial<Record<'nama' | 'wa' | 'mapel' | 'jenjang', string>>;

export function validateOrder(input: OrderInput): OrderErrors {
  const errors: OrderErrors = {};
  const nama = input.nama.trim();
  if (nama.length < 2 || nama.length > 100) errors.nama = 'Isi nama (2–100 huruf).';
  if (!/^62[0-9]{8,13}$/.test(normalizeWhatsapp(input.wa.trim()))) errors.wa = 'Nomor WhatsApp belum benar, contoh 0812 3456 7890.';
  if (input.mapel.trim().length < 1 || input.mapel.trim().length > 50) errors.mapel = 'Pilih mapel.';
  if (input.jenjang.trim().length < 1 || input.jenjang.trim().length > 30) errors.jenjang = 'Pilih jenjang.';
  return errors;
}

/** Data untuk RPC submit_order; kunci opsional hanya dikirim bila ada. */
export function toOrderPayload(input: OrderInput): Record<string, unknown> {
  const payload: Record<string, unknown> = {
    nama: input.nama.trim(),
    wa: input.wa.trim(),
    mapel: input.mapel.trim(),
    jenjang: input.jenjang.trim(),
  };
  if (input.attemptId) payload.diagnostic_attempt_id = input.attemptId;
  if (input.packageId) payload.package_id = input.packageId;
  if (input.tutor) payload.notes = `Tutor pilihan: ${input.tutor}`;
  return payload;
}

const ERROR_MESSAGES: Array<[string, string]> = [
  ['rate_limited', 'Kamu sudah terlalu sering mengirim orderan. Coba lagi dalam satu jam.'],
  ['duplicate', 'Orderan untuk mapel ini sudah masuk dan sedang diproses admin. Mohon tunggu kabar lewat WhatsApp.'],
  ['invalid_input:wa', 'Nomor WhatsApp belum benar.'],
  ['invalid_input', 'Ada isian yang belum benar. Periksa lagi formulirnya.'],
  ['invalid_session', 'Sesi tidak valid. Muat ulang halaman lalu coba lagi.'],
];

export function orderErrorMessage(raw: string): string {
  const hit = ERROR_MESSAGES.find(([code]) => raw.includes(code));
  return hit ? hit[1] : 'Orderan belum bisa dikirim. Coba lagi sebentar lagi.';
}
