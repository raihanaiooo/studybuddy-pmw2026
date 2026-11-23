import { DOCUMENT_LABELS, type DocumentType } from '../types/tutor';

/** Dokumen pelamar: Transkrip dan KTM wajib, dua sertifikat opsional. */
export const DOCUMENT_SLOTS: ReadonlyArray<{ type: DocumentType; label: string; required: boolean; hint: string }> = [
  { type: 'transkrip', label: DOCUMENT_LABELS.transkrip, required: true, hint: 'PDF dari portal akademik atau foto yang jelas. Nama dan IPK harus terbaca.' },
  { type: 'kartu_identitas_pelajar', label: DOCUMENT_LABELS.kartu_identitas_pelajar, required: true, hint: 'Foto bagian depan KTM. Semua tulisan harus terbaca, tidak terpotong.' },
  { type: 'sertifikat_prestasi', label: DOCUMENT_LABELS.sertifikat_prestasi, required: false, hint: 'Contoh: juara olimpiade atau lomba karya tulis. Boleh dilewati.' },
  { type: 'sertifikat_bahasa', label: DOCUMENT_LABELS.sertifikat_bahasa, required: false, hint: 'Contoh: TOEFL, IELTS, atau JLPT. Boleh dilewati.' },
];

export const MAX_DOCUMENT_BYTES = 3 * 1024 * 1024;

export const DOCUMENTS_BUCKET = 'tutor-applications';

const CONTENT_TYPES: Record<string, string> = {
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  pdf: 'application/pdf',
};

function extensionOf(name: string): string {
  const dot = name.lastIndexOf('.');
  return dot >= 0 ? name.slice(dot + 1).toLowerCase() : '';
}

export function documentContentType(name: string): string {
  return CONTENT_TYPES[extensionOf(name)] ?? 'application/octet-stream';
}

/** Pesan galat untuk berkas yang tidak boleh diunggah; null bila lolos. */
export function validateDocumentFile(file: { name: string; size: number }): string | null {
  if (!(extensionOf(file.name) in CONTENT_TYPES)) return 'Berkas harus berformat JPG, PNG, atau PDF.';
  if (file.size === 0) return 'Berkas kosong.';
  if (file.size > MAX_DOCUMENT_BYTES) return 'Ukuran berkas maksimal 3 MB.';
  return null;
}

/** Jalur di penyimpanan; nama asli berkas tidak dipakai (bisa berisi data pribadi atau karakter aneh). */
export function documentPath(applicationId: string, type: DocumentType, fileName: string): string {
  return `${applicationId}/${type}.${extensionOf(fileName)}`;
}

export function missingRequiredDocuments(files: Partial<Record<DocumentType, unknown>>): string[] {
  return DOCUMENT_SLOTS.filter((slot) => slot.required && !files[slot.type]).map((slot) => slot.label);
}
