import { describe, expect, it } from 'vitest';
import { functionErrorMessage } from './functionError';

const respond = (status: number, body: unknown) => new Response(JSON.stringify(body), { status });

describe('functionErrorMessage', () => {
  it('memakai pesan error dari isi respons fungsi', async () => {
    const err = { message: 'Edge Function returned a non-2xx status code', context: respond(400, { error: 'Gagal membuat akun: email sudah terdaftar' }) };
    expect(await functionErrorMessage(err)).toBe('Gagal membuat akun: email sudah terdaftar');
  });

  it('404 berarti fungsi belum di-deploy', async () => {
    const err = { message: 'x', context: respond(404, { message: 'Function not found' }) };
    expect(await functionErrorMessage(err)).toContain('belum di-deploy');
  });

  it('jatuh ke pesan bawaan bila isi respons tidak terbaca', async () => {
    const err = { message: 'Failed to send a request to the Edge Function' };
    expect(await functionErrorMessage(err)).toBe('Failed to send a request to the Edge Function');
  });
});
