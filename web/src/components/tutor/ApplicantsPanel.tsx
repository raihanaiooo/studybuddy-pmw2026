import { useCallback, useEffect, useState } from 'react';
import { FileText, Loader2, MessageCircle } from 'lucide-react';
import { AddTutorModal } from './AddTutorModal';
import { useAuth } from '../../hooks/useAuth';
import { showAlert, showPrompt } from '../../lib/dialogs';
import {
  deleteApplicationDocuments,
  fetchApplications,
  signedDocumentUrl,
  updateApplication,
  type ApplicationStatus,
  type TutorApplication,
} from '../../lib/api/tutorApplications';
import { JENJANG_OPTIONS, SUBJECT_OPTIONS } from '../../lib/tutorApplication';
import { DOCUMENT_SLOTS } from '../../lib/applicationDocuments';

type Filter = ApplicationStatus | 'all';

const TABS: Array<{ value: Filter; label: string }> = [
  { value: 'baru', label: 'Baru' },
  { value: 'diterima', label: 'Diterima' },
  { value: 'ditolak', label: 'Ditolak' },
  { value: 'all', label: 'Semua' },
];

const STATUS_STYLE: Record<ApplicationStatus, string> = {
  baru: 'bg-[#FEF3C7] text-[#92400E]',
  diterima: 'bg-[#DCFCE7] text-[#166534]',
  ditolak: 'bg-[#FEE2E2] text-[#991B1B]',
};

const labelOf = (options: ReadonlyArray<{ value: string; label: string }>, value: string) =>
  options.find((o) => o.value === value)?.label ?? value;

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('id-ID', { dateStyle: 'medium', timeStyle: 'short' });
}

export function ApplicantsPanel({ onChanged }: { onChanged?: () => void }) {
  const { user } = useAuth();
  const [filter, setFilter] = useState<Filter>('baru');
  const [items, setItems] = useState<TutorApplication[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [accepting, setAccepting] = useState<TutorApplication | null>(null);

  const reload = useCallback(() => {
    setLoading(true);
    setReloadKey((k) => k + 1);
    onChanged?.();
  }, [onChanged]);

  useEffect(() => {
    let active = true;
    fetchApplications(filter)
      .then((rows) => {
        if (!active) return;
        setItems(rows);
        setError(null);
      })
      .catch((e: unknown) => {
        if (active) setError(e instanceof Error ? e.message : 'Gagal memuat pelamar.');
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => {
      active = false;
    };
  }, [filter, reloadKey]);

  function changeFilter(next: Filter) {
    setLoading(true);
    setFilter(next);
  }

  async function reject(app: TutorApplication) {
    const input = await showPrompt('Alasan penolakan (wajib):');
    if (input === null) return;
    if (input.trim() === '') {
      await showAlert('Alasan penolakan tidak boleh kosong!');
      return;
    }
    if (!user) return;
    setBusyId(app.id);
    try {
      await updateApplication(app.id, 'ditolak', user.id, input.trim());
      // Pelamar yang ditolak tidak perlu disimpan dokumen pribadinya.
      try {
        await deleteApplicationDocuments(app);
      } catch (e) {
        await showAlert('Pelamar ditolak, tetapi dokumennya belum terhapus: ' + (e instanceof Error ? e.message : ''));
      }
      reload();
    } catch (e) {
      await showAlert(e instanceof Error ? e.message : 'Gagal menyimpan.');
    } finally {
      setBusyId(null);
    }
  }

  async function openDocument(path: string) {
    const tab = window.open('', '_blank');
    try {
      const url = await signedDocumentUrl(path);
      if (tab) tab.location.href = url;
      else window.location.href = url;
    } catch (e) {
      tab?.close();
      await showAlert('Dokumen tidak bisa dibuka: ' + (e instanceof Error ? e.message : ''));
    }
  }

  async function markAccepted(app: TutorApplication) {
    if (!user) return;
    try {
      await updateApplication(app.id, 'diterima', user.id);
    } catch (e) {
      await showAlert('Akun tutor sudah dibuat, tetapi status pelamar gagal diperbarui: ' + (e instanceof Error ? e.message : ''));
    }
    reload();
  }

  return (
    <div className="space-y-6">
      <p className="text-sm text-[var(--mute)]">
        Pendaftaran dari landing page. Periksa data dan dokumen dulu sebelum memverifikasi.
      </p>

      <div className="flex flex-wrap gap-2">
        {TABS.map((t) => (
          <button
            key={t.value}
            type="button"
            onClick={() => changeFilter(t.value)}
            aria-pressed={filter === t.value}
            className={`px-4 py-2 rounded-lg border font-semibold text-sm ${filter === t.value ? 'bg-[var(--blue)] border-[var(--blue)] text-white' : 'border-[var(--line)] text-[var(--ink)] hover:bg-[var(--hov)]'}`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {loading && (
        <div className="flex items-center gap-2 text-[var(--mute)] font-semibold py-10">
          <Loader2 className="animate-spin" size={18} /> Memuat pelamar...
        </div>
      )}

      {!loading && error && (
        <div role="alert" className="card p-5 text-red-700 font-semibold">
          Pelamar tidak bisa dimuat: {error}
        </div>
      )}

      {!loading && !error && items.length === 0 && <div className="card p-8 text-center text-[var(--mute)]">Belum ada pelamar di tab ini.</div>}

      {!loading && !error && (
        <ul className="grid gap-4">
          {items.map((app) => (
            <li key={app.id} className="card p-5">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <h3 className="font-extrabold text-[var(--ink)] text-lg">{app.full_name}</h3>
                  <p className="text-sm text-[var(--mute)]">
                    {app.university}
                    {app.major ? ` · ${app.major}` : ''}
                    {app.semester ? ` · semester ${app.semester}` : ''}
                  </p>
                </div>
                <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${STATUS_STYLE[app.status]}`}>{app.status}</span>
              </div>

              <dl className="mt-4 grid sm:grid-cols-2 gap-x-6 gap-y-2 text-sm">
                <div><dt className="font-semibold text-[var(--mute)]">Mapel</dt><dd className="text-[var(--ink)]">{app.subjects.map((s) => labelOf(SUBJECT_OPTIONS, s)).join(', ')}</dd></div>
                <div><dt className="font-semibold text-[var(--mute)]">Jenjang</dt><dd className="text-[var(--ink)]">{app.jenjang.map((j) => labelOf(JENJANG_OPTIONS, j)).join(', ')}</dd></div>
                <div><dt className="font-semibold text-[var(--mute)]">Email</dt><dd className="text-[var(--ink)] break-all">{app.email}</dd></div>
                <div><dt className="font-semibold text-[var(--mute)]">WhatsApp</dt><dd className="text-[var(--ink)]">+{app.whatsapp}</dd></div>
                {app.experience && (
                  <div className="sm:col-span-2"><dt className="font-semibold text-[var(--mute)]">Pengalaman</dt><dd className="text-[var(--ink)] whitespace-pre-line">{app.experience}</dd></div>
                )}
                {app.admin_note && (
                  <div className="sm:col-span-2"><dt className="font-semibold text-[var(--mute)]">Catatan admin</dt><dd className="text-[var(--ink)]">{app.admin_note}</dd></div>
                )}
              </dl>

              {DOCUMENT_SLOTS.some((s) => app.documents?.[s.type]) && (
                <div className="mt-4">
                  <p className="text-sm font-semibold text-[var(--mute)]">Dokumen</p>
                  <div className="mt-2 flex flex-wrap gap-2">
                    {DOCUMENT_SLOTS.filter((s) => app.documents?.[s.type]).map((s) => (
                      <button key={s.type} type="button" className="btn" onClick={() => openDocument(app.documents[s.type] as string)}>
                        <FileText size={16} /> {s.label}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              <div className="mt-4 flex flex-wrap items-center gap-2 pt-4 border-t border-[var(--line)]">
                <p className="text-xs text-[var(--mute)] mr-auto">Masuk {formatDate(app.created_at)}</p>
                <a
                  href={`https://wa.me/${app.whatsapp}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn"
                >
                  <MessageCircle size={16} /> Chat WhatsApp
                </a>
                {app.status === 'baru' && (
                  <>
                    <button type="button" className="btn" disabled={busyId === app.id} onClick={() => reject(app)}>
                      Tolak
                    </button>
                    <button type="button" className="btn btn-p" disabled={busyId === app.id} onClick={() => setAccepting(app)}>
                      Verifikasi
                    </button>
                  </>
                )}
              </div>
            </li>
          ))}
        </ul>
      )}

      {accepting && (
        <AddTutorModal
          key={accepting.id}
          isOpen
          verificationStatus="verified"
          applicationId={accepting.id}
          initial={{
            full_name: accepting.full_name,
            email: accepting.email,
            phone: accepting.whatsapp,
            university: accepting.university,
            bio: accepting.experience ?? '',
            subjects: accepting.subjects,
            jenjang_diajar: accepting.jenjang,
          }}
          onClose={() => setAccepting(null)}
          onSuccess={() => {
            const app = accepting;
            setAccepting(null);
            void markAccepted(app);
          }}
        />
      )}
    </div>
  );
}
