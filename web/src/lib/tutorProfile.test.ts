import { describe, expect, it } from 'vitest';
import { validateTutorProfile, type TutorProfileForm } from './tutorProfile';

const ok: TutorProfileForm = {
  name: 'Dewi Lestari',
  university: 'Universitas Indonesia',
  gpa: '3,75',
  bio: '',
  whatsapp: '0812 3456 7890',
  email: 'dewi@example.com',
  payout: 'BCA 1234567890 a.n. Dewi',
};

describe('validateTutorProfile', () => {
  it('data benar: tanpa galat, WhatsApp dinormalkan ke 62..., IPK jadi angka', () => {
    const r = validateTutorProfile(ok);
    expect(r.errors).toEqual({});
    expect(r.value.whatsapp).toBe('6281234567890');
    expect(r.value.gpa).toBe(3.75);
  });

  it('kolom opsional boleh kosong', () => {
    const r = validateTutorProfile({ ...ok, university: '', gpa: '', whatsapp: '', email: '', payout: '' });
    expect(r.errors).toEqual({});
    expect(r.value.gpa).toBeNull();
    expect(r.value.whatsapp).toBeNull();
  });

  it('nama wajib dan minimal 2 huruf', () => {
    expect(validateTutorProfile({ ...ok, name: '   ' }).errors.name).toBeTruthy();
    expect(validateTutorProfile({ ...ok, name: 'A' }).errors.name).toBeTruthy();
  });

  it('IPK harus 0 sampai 4', () => {
    expect(validateTutorProfile({ ...ok, gpa: '4,5' }).errors.gpa).toBeTruthy();
    expect(validateTutorProfile({ ...ok, gpa: '-1' }).errors.gpa).toBeTruthy();
    expect(validateTutorProfile({ ...ok, gpa: 'abc' }).errors.gpa).toBeTruthy();
    expect(validateTutorProfile({ ...ok, gpa: '3.756' }).errors.gpa).toBeTruthy();
    expect(validateTutorProfile({ ...ok, gpa: '4' }).errors.gpa).toBeUndefined();
  });

  it('WhatsApp: terima 08..., +62..., 62...; tolak huruf dan yang terlalu pendek', () => {
    for (const w of ['081234567890', '+62 812-3456-7890', '6281234567890']) {
      expect(validateTutorProfile({ ...ok, whatsapp: w }).errors.whatsapp).toBeUndefined();
    }
    for (const w of ['0812abc', '0812', '12345678901234567']) {
      expect(validateTutorProfile({ ...ok, whatsapp: w }).errors.whatsapp).toBeTruthy();
    }
  });

  it('email harus berformat email', () => {
    expect(validateTutorProfile({ ...ok, email: 'dewi@' }).errors.email).toBeTruthy();
    expect(validateTutorProfile({ ...ok, email: 'dewi example.com' }).errors.email).toBeTruthy();
  });

  it('batas panjang: bio 1000, rekening 200', () => {
    expect(validateTutorProfile({ ...ok, bio: 'x'.repeat(1001) }).errors.bio).toBeTruthy();
    expect(validateTutorProfile({ ...ok, payout: 'x'.repeat(201) }).errors.payout).toBeTruthy();
  });
});
