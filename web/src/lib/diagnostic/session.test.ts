import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

function fakeStorage(opts: { throwOnSet?: boolean; throwOnGet?: boolean } = {}) {
  const data = new Map<string, string>();
  return {
    data,
    getItem(key: string) {
      if (opts.throwOnGet) throw new Error('storage blocked');
      return data.has(key) ? data.get(key)! : null;
    },
    setItem(key: string, value: string) {
      if (opts.throwOnSet) throw new Error('storage blocked');
      data.set(key, value);
    },
    removeItem(key: string) {
      data.delete(key);
    },
  };
}

async function loadModule() {
  vi.resetModules();
  return import('./session');
}

describe('getClientSessionId', () => {
  beforeEach(() => {
    vi.stubGlobal('localStorage', fakeStorage());
    vi.stubGlobal('sessionStorage', fakeStorage());
  });
  afterEach(() => vi.unstubAllGlobals());

  it('mengembalikan nilai sama pada panggilan berulang', async () => {
    const { getClientSessionId } = await loadModule();
    const first = getClientSessionId();
    expect(first.length).toBeGreaterThan(7);
    expect(getClientSessionId()).toBe(first);
  });

  it('tetap sama setelah modul dimuat ulang (disimpan di localStorage)', async () => {
    const first = (await loadModule()).getClientSessionId();
    const second = (await loadModule()).getClientSessionId();
    expect(second).toBe(first);
  });

  it('jatuh ke ID di memori yang stabil bila localStorage diblokir (Review Focus 4)', async () => {
    vi.stubGlobal('localStorage', fakeStorage({ throwOnSet: true, throwOnGet: true }));
    const { getClientSessionId } = await loadModule();
    const id = getClientSessionId();
    expect(id.length).toBeGreaterThan(7);
    expect(getClientSessionId()).toBe(id);
  });
});

describe('draft jawaban', () => {
  beforeEach(() => {
    vi.stubGlobal('localStorage', fakeStorage());
    vi.stubGlobal('sessionStorage', fakeStorage());
  });
  afterEach(() => vi.unstubAllGlobals());

  it('menyimpan lalu memuat draft yang sama (Review Focus 5)', async () => {
    const { saveDraft, loadDraft } = await loadModule();
    saveDraft({ 'q-1': 2, 'q-2': 0 });
    expect(loadDraft()).toEqual({ 'q-1': 2, 'q-2': 0 });
  });

  it('mengembalikan objek kosong bila belum ada draft', async () => {
    const { loadDraft } = await loadModule();
    expect(loadDraft()).toEqual({});
  });

  it('mengembalikan objek kosong bila isi storage rusak', async () => {
    const storage = fakeStorage();
    storage.setItem('sb_diag_draft', '{bukan json');
    vi.stubGlobal('sessionStorage', storage);
    const { loadDraft } = await loadModule();
    expect(loadDraft()).toEqual({});
  });

  it('mengabaikan draft yang bukan objek angka', async () => {
    const storage = fakeStorage();
    storage.setItem('sb_diag_draft', '[1,2,3]');
    vi.stubGlobal('sessionStorage', storage);
    const { loadDraft } = await loadModule();
    expect(loadDraft()).toEqual({});

    storage.setItem('sb_diag_draft', JSON.stringify({ a: 1, b: 'x', c: -1, d: 1.5 }));
    expect(loadDraft()).toEqual({ a: 1 });
  });

  it('clearDraft mengosongkan draft', async () => {
    const { saveDraft, loadDraft, clearDraft } = await loadModule();
    saveDraft({ a: 1 });
    clearDraft();
    expect(loadDraft()).toEqual({});
  });

  it('saveDraft tidak melempar bila sessionStorage diblokir', async () => {
    vi.stubGlobal('sessionStorage', fakeStorage({ throwOnSet: true, throwOnGet: true }));
    const { saveDraft, loadDraft } = await loadModule();
    expect(() => saveDraft({ a: 1 })).not.toThrow();
    expect(loadDraft()).toEqual({});
  });
});
