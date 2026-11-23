import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { CheckCircle2, Loader2 } from 'lucide-react';
import { PublicLayout } from '../components/layout/PublicLayout';
import { fetchLatestOprec, submitTutorApplication } from '../lib/api/tutorApplications';
import { CAMPUS_SUGGESTIONS } from '../lib/campuses';
import { DOCUMENT_SLOTS, missingRequiredDocuments, validateDocumentFile } from '../lib/applicationDocuments';
import type { DocumentType } from '../types/tutor';
import {
  emptyApplicationForm,
  JENJANG_OPTIONS,
  oprecState,
  SUBJECT_OPTIONS,
  validateApplication,
  type ApplicationErrors,
  type ApplicationForm,
} from '../lib/tutorApplication';

const inputClass =
  'w-full mt-2 bg-[var(--bg)] border-2 border-[var(--line)] rounded-2xl px-4 py-3 font-semibold text-[var(--ink)] placeholder:text-[var(--mute)] focus:outline-none focus:border-[var(--blue)]';
const primaryButton =
  'inline-flex items-center justify-center gap-2 font-extrabold rounded-2xl py-3 px-6 bg-[var(--blue)] text-white shadow-[0_5px_0_var(--bdark)] hover:-translate-y-0.5 hover:shadow-[0_7px_0_var(--bdark)] active:translate-y-1 active:shadow-none transition-all disabled:opacity-50 disabled:pointer-events-none';

type Phase = 'loading' | 'closed' | 'form' | 'done';

export function TutorApplyPage() {
  const [phase, setPhase] = useState<Phase>('loading');
  const [closedMessage, setClosedMessage] = useState('');
  const [form, setForm] = useState<ApplicationForm>(emptyApplicationForm());
  const [errors, setErrors] = useState<ApplicationErrors>({});
  const [submitError, setSubmitError] = useState('');
  const [files, setFiles] = useState<Partial<Record<DocumentType, File>>>({});
  const [fileErrors, setFileErrors] = useState<Partial<Record<DocumentType, string>>>({});
  const sending = useRef(false);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    let active = true;
    fetchLatestOprec().then((row) => {
      if (!active) return;
      const state = oprecState(row, new Date());
      if (state.open) setPhase('form');
      else {
        setClosedMessage(state.message ?? 'Pendaftaran tutor sedang ditutup.');
        setPhase('closed');
      }
    });
    return () => {
      active = false;
    };
  }, []);

  function setField<K extends keyof ApplicationForm>(key: K, value: ApplicationForm[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
    setErrors((prev) => ({ ...prev, [key]: undefined }));
  }

  function toggle(key: 'subjects' | 'jenjang', value: string) {
    setField(key, form[key].includes(value) ? form[key].filter((v) => v !== value) : [...form[key], value]);
  }

  function pickFile(type: DocumentType, file: File | undefined) {
    const problem = file ? validateDocumentFile(file) : null;
    setFileErrors((prev) => ({ ...prev, [type]: problem ?? undefined }));
    setFiles((prev) => {
      const next = { ...prev };
      if (file && !problem) next[type] = file;
      else delete next[type];
      return next;
    });
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (sending.current) return;
    const found = validateApplication(form);
    setErrors(found);
    const missing = missingRequiredDocuments(files);
    const nextFileErrors: Partial<Record<DocumentType, string>> = { ...fileErrors };
    for (const slot of DOCUMENT_SLOTS) {
      if (slot.required && !files[slot.type] && !nextFileErrors[slot.type]) nextFileErrors[slot.type] = `${slot.label} wajib diunggah.`;
    }
    setFileErrors(nextFileErrors);
    if (Object.keys(found).length > 0 || missing.length > 0) return;

    sending.current = true;
    setSubmitting(true);
    setSubmitError('');
    try {
      await submitTutorApplication(form, files);
      setPhase('done');
    } catch (err) {
      setSubmitError(err instanceof Error ? err.message : 'Pendaftaran belum bisa dikirim.');
    } finally {
      sending.current = false;
      setSubmitting(false);
    }
  }

  const fieldError = (key: keyof ApplicationForm) =>
    errors[key] ? (
      <p id={`err-${key}`} role="alert" className="mt-1 text-sm font-semibold text-red-700">
        {errors[key]}
      </p>
    ) : null;

  return (
    <PublicLayout>
      <header className="border-b border-[var(--line)] bg-[var(--bg)]/90">
        <div className="max-w-3xl mx-auto px-5 h-16 flex items-center justify-between">
          <Link to="/" className="text-xl font-extrabold tracking-tight text-[var(--ink)]">
            Study<span className="text-[var(--blue)]">Buddy</span>
          </Link>
          <Link to="/" className="text-sm font-bold text-[var(--mute)] hover:text-[var(--ink)]">
            Kembali ke beranda
          </Link>
        </div>
      </header>

      <main className="flex-1 max-w-3xl w-full mx-auto px-5 py-10 md:py-14">
        {phase === 'loading' && (
          <div className="flex items-center justify-center gap-3 py-24 text-[var(--mute)] font-semibold">
            <Loader2 className="animate-spin" size={20} /> Memuat...
          </div>
        )}

        {phase === 'closed' && (
          <div className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 text-center">
            <h1 className="text-2xl font-extrabold text-[var(--ink)]">{closedMessage}</h1>
            <p className="mt-3 text-[var(--mute)]">Pantau terus info oprec di beranda untuk batch berikutnya.</p>
            <Link to="/" className={`${primaryButton} mt-6`}>
              Kembali ke beranda
            </Link>
          </div>
        )}

        {phase === 'done' && (
          <div className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-8 md:p-10 text-center">
            <CheckCircle2 className="mx-auto text-[var(--blue)]" size={48} />
            <h1 className="mt-4 text-3xl font-extrabold text-[var(--ink)]">Pendaftaran terkirim.</h1>
            <p className="mt-3 text-[var(--mute)] leading-relaxed">
              Terima kasih sudah mendaftar jadi Buddy. Admin akan memeriksa data dan dokumenmu, lalu menghubungi lewat WhatsApp. Akun Buddy dibuat setelah dokumenmu lolos pemeriksaan.
            </p>
            <Link to="/" className={`${primaryButton} mt-6`}>
              Kembali ke beranda
            </Link>
          </div>
        )}

        {phase === 'form' && (
          <form onSubmit={handleSubmit} noValidate className="rounded-[2rem] border-2 border-[var(--line)] bg-[var(--card)] p-6 md:p-10 grid gap-6">
            <div>
              <h1 className="text-3xl md:text-5xl font-extrabold leading-[1.05] text-[var(--ink)]">Daftar jadi Buddy.</h1>
              <p className="mt-4 text-[var(--mute)] leading-relaxed">
                Isi data di bawah dan unggah dokumenmu. Dokumen hanya dilihat admin Study Buddy untuk verifikasi.
              </p>
            </div>

            <div className="grid sm:grid-cols-2 gap-5">
              <label className="block font-bold text-[var(--ink)]">
                Nama lengkap
                <input className={inputClass} value={form.full_name} onChange={(e) => setField('full_name', e.target.value)} autoComplete="name"
                  aria-invalid={!!errors.full_name} aria-describedby={errors.full_name ? 'err-full_name' : undefined} maxLength={100} />
                {fieldError('full_name')}
              </label>
              <label className="block font-bold text-[var(--ink)]">
                Nomor WhatsApp
                <input className={inputClass} inputMode="tel" value={form.whatsapp} onChange={(e) => setField('whatsapp', e.target.value)} placeholder="08xxxxxxxxxx" autoComplete="tel"
                  aria-invalid={!!errors.whatsapp} aria-describedby={errors.whatsapp ? 'err-whatsapp' : undefined} />
                {fieldError('whatsapp')}
              </label>
              <label className="block font-bold text-[var(--ink)] sm:col-span-2">
                Email
                <input className={inputClass} type="email" value={form.email} onChange={(e) => setField('email', e.target.value)} placeholder="nama@email.com" autoComplete="email"
                  aria-invalid={!!errors.email} aria-describedby={errors.email ? 'err-email' : undefined} maxLength={150} />
                {fieldError('email')}
              </label>
              <label className="block font-bold text-[var(--ink)]">
                Kampus
                <input className={inputClass} list="daftar-kampus" value={form.university} onChange={(e) => setField('university', e.target.value)} placeholder="Ketik, lalu pilih atau isi sendiri"
                  aria-invalid={!!errors.university} aria-describedby={errors.university ? 'err-university' : undefined} maxLength={100} />
                <datalist id="daftar-kampus">
                  {CAMPUS_SUGGESTIONS.map((c) => (
                    <option key={c} value={c} />
                  ))}
                </datalist>
                {fieldError('university')}
              </label>
              <div className="grid grid-cols-3 gap-3">
                <label className="block font-bold text-[var(--ink)] col-span-2">
                  Jurusan <span className="font-medium text-[var(--mute)]">(opsional)</span>
                  <input className={inputClass} value={form.major} onChange={(e) => setField('major', e.target.value)} maxLength={100} />
                  {fieldError('major')}
                </label>
                <label className="block font-bold text-[var(--ink)]">
                  Semester
                  <input className={inputClass} inputMode="numeric" value={form.semester} onChange={(e) => setField('semester', e.target.value)} maxLength={2}
                    aria-invalid={!!errors.semester} aria-describedby={errors.semester ? 'err-semester' : undefined} />
                  {fieldError('semester')}
                </label>
              </div>
            </div>

            <fieldset>
              <legend className="font-bold text-[var(--ink)]">Mata pelajaran yang diajar</legend>
              <div className="mt-3 flex flex-wrap gap-2">
                {SUBJECT_OPTIONS.map((o) => (
                  <button key={o.value} type="button" aria-pressed={form.subjects.includes(o.value)} onClick={() => toggle('subjects', o.value)}
                    className={`px-4 py-2 rounded-full border-2 font-bold text-sm transition-colors ${form.subjects.includes(o.value) ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'border-[var(--line)] text-[var(--ink)] hover:border-[var(--blue)]'}`}>
                    {o.label}
                  </button>
                ))}
              </div>
              {fieldError('subjects')}
            </fieldset>

            <fieldset>
              <legend className="font-bold text-[var(--ink)]">Jenjang yang diajar</legend>
              <div className="mt-3 flex flex-wrap gap-2">
                {JENJANG_OPTIONS.map((o) => (
                  <button key={o.value} type="button" aria-pressed={form.jenjang.includes(o.value)} onClick={() => toggle('jenjang', o.value)}
                    className={`px-4 py-2 rounded-full border-2 font-bold text-sm transition-colors ${form.jenjang.includes(o.value) ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'border-[var(--line)] text-[var(--ink)] hover:border-[var(--blue)]'}`}>
                    {o.label}
                  </button>
                ))}
              </div>
              {fieldError('jenjang')}
            </fieldset>

            <label className="block font-bold text-[var(--ink)]">
              Pengalaman mengajar <span className="font-medium text-[var(--mute)]">(opsional)</span>
              <textarea className={`${inputClass} resize-none`} rows={3} value={form.experience} onChange={(e) => setField('experience', e.target.value)} maxLength={1000}
                placeholder="Mis. privat 2 tahun, asisten praktikum, juara olimpiade" />
              {fieldError('experience')}
            </label>

            <fieldset className="grid gap-4">
              <legend className="font-bold text-[var(--ink)]">Dokumen</legend>
              <p className="text-sm text-[var(--mute)]">Format JPG, PNG, atau PDF, maksimal 3 MB per berkas.</p>
              {DOCUMENT_SLOTS.map((slot) => (
                <label key={slot.type} className="block font-bold text-[var(--ink)]">
                  {slot.label}{' '}
                  <span className="font-medium text-[var(--mute)]">{slot.required ? '(wajib)' : '(opsional)'}</span>
                  <input
                    type="file"
                    accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf"
                    onChange={(e) => pickFile(slot.type, e.target.files?.[0])}
                    aria-invalid={!!fileErrors[slot.type]}
                    aria-describedby={fileErrors[slot.type] ? `err-${slot.type}` : undefined}
                    className="mt-2 block w-full text-sm font-semibold text-[var(--ink)] file:mr-3 file:rounded-xl file:border-0 file:bg-[var(--hov)] file:px-4 file:py-2 file:font-bold file:text-[var(--blue)]"
                  />
                  {files[slot.type] && <span className="mt-1 block text-sm font-medium text-[var(--mute)]">{files[slot.type]?.name}</span>}
                  {fileErrors[slot.type] && (
                    <p id={`err-${slot.type}`} role="alert" className="mt-1 text-sm font-semibold text-red-700">{fileErrors[slot.type]}</p>
                  )}
                </label>
              ))}
            </fieldset>

            {submitError && (
              <p role="alert" className="rounded-2xl border-2 border-red-300 bg-red-50 px-4 py-3 text-sm font-semibold text-red-700">
                {submitError}
              </p>
            )}

            <button type="submit" disabled={submitting} className={`${primaryButton} justify-self-start`}>
              {submitting ? 'Mengirim...' : 'Kirim pendaftaran'}
            </button>
          </form>
        )}
      </main>
    </PublicLayout>
  );
}
