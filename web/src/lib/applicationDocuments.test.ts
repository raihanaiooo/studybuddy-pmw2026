import { describe, expect, it } from 'vitest';
import {
  DOCUMENT_SLOTS,
  MAX_DOCUMENT_BYTES,
  documentContentType,
  documentPath,
  missingRequiredDocuments,
  validateDocumentFile,
} from './applicationDocuments';

const APP = '0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
const file = (name: string, size = 1000) => ({ name, size });

describe('DOCUMENT_SLOTS', () => {
  it('Transkrip dan KTM wajib, dua sertifikat opsional', () => {
    expect(DOCUMENT_SLOTS.map((s) => [s.type, s.required])).toEqual([
      ['transkrip', true],
      ['kartu_identitas_pelajar', true],
      ['sertifikat_prestasi', false],
      ['sertifikat_bahasa', false],
    ]);
  });
});

describe('validateDocumentFile', () => {
  it.each(['a.jpg', 'a.JPEG', 'a.png', 'scan.PDF'])('menerima %s', (name) => {
    expect(validateDocumentFile(file(name))).toBeNull();
  });

  it('menolak jenis berkas lain', () => {
    expect(validateDocumentFile(file('virus.exe'))).toContain('JPG, PNG, atau PDF');
    expect(validateDocumentFile(file('tanpa-ekstensi'))).toContain('JPG, PNG, atau PDF');
  });

  it('menolak berkas lebih dari 3 MB dan berkas kosong', () => {
    expect(MAX_DOCUMENT_BYTES).toBe(3 * 1024 * 1024);
    expect(validateDocumentFile(file('a.pdf', MAX_DOCUMENT_BYTES + 1))).toContain('3 MB');
    expect(validateDocumentFile(file('a.pdf', MAX_DOCUMENT_BYTES))).toBeNull();
    expect(validateDocumentFile(file('a.pdf', 0))).toContain('kosong');
  });
});

describe('documentPath dan documentContentType', () => {
  it('jalur memakai id pelamar dan jenis dokumen, bukan nama asli berkas', () => {
    expect(documentPath(APP, 'transkrip', 'Transkrip Saya (final).PDF')).toBe(`${APP}/transkrip.pdf`);
    expect(documentPath(APP, 'kartu_identitas_pelajar', 'ktm.JPEG')).toBe(`${APP}/kartu_identitas_pelajar.jpeg`);
  });

  it('jenis konten sesuai ekstensi', () => {
    expect(documentContentType('a.jpg')).toBe('image/jpeg');
    expect(documentContentType('a.JPEG')).toBe('image/jpeg');
    expect(documentContentType('a.png')).toBe('image/png');
    expect(documentContentType('a.pdf')).toBe('application/pdf');
  });
});

describe('missingRequiredDocuments', () => {
  it('menyebut dokumen wajib yang belum dipilih', () => {
    expect(missingRequiredDocuments({})).toEqual(['Transkrip Nilai', 'KTM / Kartu Tanda Pelajar']);
    expect(missingRequiredDocuments({ transkrip: file('a.pdf') })).toEqual(['KTM / Kartu Tanda Pelajar']);
  });

  it('kosong bila dua dokumen wajib sudah ada', () => {
    expect(missingRequiredDocuments({ transkrip: file('a.pdf'), kartu_identitas_pelajar: file('b.jpg') })).toEqual([]);
  });
});
