import { useState } from 'react';
import { Portal } from '../ui/Portal';
import { JENJANG_OPTIONS, SUBJECT_OPTIONS } from '../../lib/tutorApplication';
import { saveTutorProfile } from '../../lib/api/tutor';
import { validateTutorProfile, type TutorProfileErrors } from '../../lib/tutorProfile';
import type { Tutor, TutorPrivate } from '../../types/tutor';

interface Props {
  tutor: Tutor;
  priv: TutorPrivate;
  onClose: () => void;
  onSaved: () => void;
}

function Chips({ options, value, onChange }: { options: ReadonlyArray<{ value: string; label: string }>; value: string[]; onChange: (v: string[]) => void }) {
  // nilai lama yang tidak ada di pilihan tetap ditampilkan agar tidak hilang diam-diam
  const extra = value.filter((v) => !options.some((o) => o.value === v)).map((v) => ({ value: v, label: v }));
  return (
    <div className="flex flex-wrap gap-2">
      {[...options, ...extra].map((o) => {
        const on = value.includes(o.value);
        return (
          <button
            key={o.value}
            type="button"
            aria-pressed={on}
            onClick={() => onChange(on ? value.filter((v) => v !== o.value) : [...value, o.value])}
            className={`px-3 py-1.5 rounded-full text-sm font-semibold border transition-colors ${
              on ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'bg-white border-[var(--line)] text-[var(--mute)] hover:bg-[var(--soft)]'
            }`}
          >
            {o.label}
          </button>
        );
      })}
    </div>
  );
}

function Field({ label, hint, error, children }: { label: string; hint?: string; error?: string; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className="text-xs font-semibold text-[var(--mute)]">{label}</span>
      {children}
      {error ? <span role="alert" className="block text-xs text-[#991B1B] font-semibold mt-1">{error}</span> : hint && <span className="block text-xs text-[var(--mute)] mt-1">{hint}</span>}
    </label>
  );
}

export function TutorEditModal({ tutor, priv, onClose, onSaved }: Props) {
  const [name, setName] = useState(tutor.full_name);
  const [university, setUniversity] = useState(tutor.university ?? '');
  const [gpa, setGpa] = useState(tutor.gpa != null ? String(tutor.gpa) : '');
  const [bio, setBio] = useState(tutor.bio ?? '');
  const [subjects, setSubjects] = useState<string[]>(tutor.subjects ?? []);
  const [jenjang, setJenjang] = useState<string[]>(tutor.jenjang_diajar ?? []);
  const [outsourced, setOutsourced] = useState(!!tutor.is_outsourced);
  const [whatsapp, setWhatsapp] = useState(priv.whatsapp ?? '');
  const [email, setEmail] = useState(priv.email ?? '');
  const [payout, setPayout] = useState(priv.payout_account ?? '');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [fieldErrors, setFieldErrors] = useState<TutorProfileErrors>({});

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const { errors, value } = validateTutorProfile({ name, university, gpa, bio, whatsapp, email, payout });
    setFieldErrors(errors);
    if (Object.keys(errors).length > 0) {
      setError('Periksa isian yang bertanda merah.');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await saveTutorProfile(
        tutor.id,
        {
          full_name: value.name,
          university: value.university,
          gpa: value.gpa,
          bio: value.bio,
          subjects,
          jenjang_diajar: jenjang,
          is_outsourced: outsourced,
        },
        { whatsapp: value.whatsapp, email: value.email, payout_account: value.payout }
      );
      onSaved();
      onClose();
    } catch (err: any) {
      setError(err?.message ?? 'Gagal menyimpan');
    } finally {
      setSaving(false);
    }
  }

  return (
    <Portal>
      <div className="fixed inset-0 bg-black/40 z-50 flex items-start sm:items-center justify-center p-4 overflow-y-auto">
        <form onSubmit={submit} noValidate className="card w-full max-w-lg p-6 my-auto space-y-4">
          <h2 className="text-xl font-bold text-[var(--ink)]">Edit Tutor</h2>

          <Field label="Nama" error={fieldErrors.name}>
            <input value={name} onChange={(e) => setName(e.target.value)} className="inp mt-1" />
          </Field>
          <div className="grid sm:grid-cols-2 gap-3">
            <Field label="Kampus" error={fieldErrors.university}>
              <input value={university} onChange={(e) => setUniversity(e.target.value)} className="inp mt-1" />
            </Field>
            <Field label="IPK" error={fieldErrors.gpa}>
              <input inputMode="decimal" value={gpa} onChange={(e) => setGpa(e.target.value)} className="inp mt-1" placeholder="3.75" />
            </Field>
          </div>
          <Field label="Bio" error={fieldErrors.bio}>
            <textarea rows={3} value={bio} onChange={(e) => setBio(e.target.value)} className="inp mt-1" />
          </Field>
          <div>
            <span className="text-xs font-semibold text-[var(--mute)]">Mata pelajaran</span>
            <div className="mt-1"><Chips options={SUBJECT_OPTIONS} value={subjects} onChange={setSubjects} /></div>
          </div>
          <div>
            <span className="text-xs font-semibold text-[var(--mute)]">Jenjang diajar</span>
            <div className="mt-1"><Chips options={JENJANG_OPTIONS} value={jenjang} onChange={setJenjang} /></div>
          </div>
          <label className="flex items-center gap-2 text-sm font-semibold">
            <input type="checkbox" checked={outsourced} onChange={(e) => setOutsourced(e.target.checked)} />
            Tutor outsourcing
          </label>

          <div className="pt-3 border-t border-[var(--line)] space-y-3">
            <p className="text-xs text-[var(--mute)]">Data pribadi: hanya admin yang bisa melihat. Dipakai untuk menghubungi dan membayar gaji.</p>
            <div className="grid sm:grid-cols-2 gap-3">
              <Field label="WhatsApp" error={fieldErrors.whatsapp}>
                <input inputMode="tel" value={whatsapp} onChange={(e) => setWhatsapp(e.target.value)} className="inp mt-1" placeholder="08xxxxxxxxxx" />
              </Field>
              <Field label="Email" error={fieldErrors.email}>
                <input type="text" inputMode="email" value={email} onChange={(e) => setEmail(e.target.value)} className="inp mt-1" />
              </Field>
            </div>
            <Field label="Rekening / e-wallet" error={fieldErrors.payout} hint="Contoh: BCA 1234567890 a.n. Nama, atau DANA 08xxxxxxxxxx">
              <input value={payout} onChange={(e) => setPayout(e.target.value)} className="inp mt-1" />
            </Field>
          </div>

          {error && <p className="text-sm text-[#991B1B]">{error}</p>}
          <div className="flex justify-end gap-2 pt-2">
            <button type="button" onClick={onClose} className="px-4 py-2 font-bold text-[var(--mute)]">Batal</button>
            <button type="submit" disabled={saving} className="btn btn-p">{saving ? 'Menyimpan...' : 'Simpan'}</button>
          </div>
        </form>
      </div>
    </Portal>
  );
}
