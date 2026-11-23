const SESSION_KEY = 'sb_diag_session';
const draftKey = (testCode: string) => `sb_diag_draft_${testCode}`;

let memorySessionId: string | null = null;

function newId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return `s-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 12)}`;
}

/** ID anonim per browser untuk pembatasan laju. Jatuh ke memori bila localStorage diblokir. */
export function getClientSessionId(): string {
  if (memorySessionId) return memorySessionId;
  try {
    const stored = localStorage.getItem(SESSION_KEY);
    if (stored) {
      memorySessionId = stored;
      return stored;
    }
  } catch {
    // storage diblokir: lanjut dengan ID di memori
  }
  memorySessionId = newId();
  try {
    localStorage.setItem(SESSION_KEY, memorySessionId);
  } catch {
    // tidak apa-apa: ID tetap stabil selama halaman terbuka
  }
  return memorySessionId;
}

export type Draft = Record<string, number>;

export function saveDraft(testCode: string, answers: Draft): void {
  try {
    sessionStorage.setItem(draftKey(testCode), JSON.stringify(answers));
  } catch {
    // storage diblokir: draft tidak tersimpan, tes tetap jalan
  }
}

export function loadDraft(testCode: string): Draft {
  try {
    const raw = sessionStorage.getItem(draftKey(testCode));
    if (!raw) return {};
    const parsed: unknown = JSON.parse(raw);
    if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) return {};
    const draft: Draft = {};
    for (const [key, value] of Object.entries(parsed)) {
      if (typeof value === 'number' && Number.isInteger(value) && value >= 0) draft[key] = value;
    }
    return draft;
  } catch {
    return {};
  }
}

export function clearDraft(testCode: string): void {
  try {
    sessionStorage.removeItem(draftKey(testCode));
  } catch {
    // diabaikan
  }
}
