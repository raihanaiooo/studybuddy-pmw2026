import { useEffect, useState } from 'react';
import type { TutorDocument } from '../../types/tutor';
import {
  DOCUMENT_LABELS,
  DOCUMENT_REQUIREMENTS,
} from '../../types/tutor';
import { getSignedUrl } from '../../lib/api/tutor';

interface Props {
  document: TutorDocument;
}

const statusConfig: Record<
  string,
  { label: string; className: string }
> = {
  belum_upload: {
    label: 'Belum Upload',
    className: 'bg-[#9CA3AF]/15 text-[#9CA3AF]',
  },
  menunggu_verifikasi: {
    label: 'Menunggu Verifikasi',
    className: 'bg-[#F4A200]/15 text-[#F4A200]',
  },
  terverifikasi: {
    label: 'Terverifikasi',
    className: 'bg-[#00C853]/15 text-[#00C853]',
  },
  ditolak: {
    label: 'Ditolak',
    className: 'bg-[#E53935]/15 text-[#E53935]',
  },
};

export function DocumentPreview({ document }: Props) {
  const [signedUrl, setSignedUrl] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const docStatus = statusConfig[document.status] ?? statusConfig.belum_upload;
  const label = DOCUMENT_LABELS[document.jenis_dokumen] ?? document.jenis_dokumen;
  const requirement =
    DOCUMENT_REQUIREMENTS[document.jenis_dokumen] ?? 'Wajib';

  useEffect(() => {
    if (!document.file_url) return;
    let mounted = true;

    async function load() {
      setLoading(true);
      try {
        const url = await getSignedUrl(document.file_url!);
        if (mounted) setSignedUrl(url);
      } catch (e) {
        if (mounted) {
          setError(e instanceof Error ? e.message : 'Gagal memuat dokumen');
        }
      } finally {
        if (mounted) setLoading(false);
      }
    }

    load();
    return () => {
      mounted = false;
    };
  }, [document.file_url]);

  const isPdf = signedUrl?.toLowerCase().includes('.pdf') ?? false;

  return (
    <div className="border border-[#E5E7EB] rounded-xl overflow-hidden">
      {/* Header */}
      <div className="p-4 bg-[#F5F6FA] border-b border-[#E5E7EB] flex items-center justify-between gap-3">
        <div className="min-w-0">
          <h4 className="font-semibold text-[#1A1F3C] text-sm truncate">
            {label}
          </h4>
          <p className="text-xs text-[#6B7280]">{requirement}</p>
        </div>
        <span
          className={`px-3 py-1 rounded-full text-xs font-bold shrink-0 ${docStatus.className}`}
        >
          {docStatus.label}
        </span>
      </div>

      {/* Content */}
      <div className="p-4">
        {!document.file_url && (
          <div className="py-8 text-center text-sm text-[#9CA3AF]">
            Belum ada file diunggah
          </div>
        )}

        {loading && (
          <div className="py-8 flex justify-center">
            <div className="w-8 h-8 border-3 border-[#1A5EAA] border-t-transparent rounded-full animate-spin" />
          </div>
        )}

        {error && (
          <div className="py-4 text-center text-sm text-[#E53935]">
            {error}
          </div>
        )}

        {signedUrl && !loading && (
          <div>
            {isPdf ? (
              <iframe
                src={signedUrl}
                className="w-full h-80 rounded-lg border border-[#E5E7EB]"
                title={label}
              />
            ) : (
              <img
                src={signedUrl}
                alt={label}
                className="w-full max-h-80 object-contain rounded-lg bg-[#F5F6FA]"
              />
            )}

            <a
              href={signedUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-3 inline-flex items-center gap-2 text-sm text-[#1A5EAA] hover:underline font-medium"
            >
              <span>🔗</span> Buka di tab baru
            </a>
          </div>
        )}

        {document.rejection_note && (
          <div className="mt-3 bg-[#E53935]/10 border border-[#E53935]/20 rounded-lg p-3 text-xs text-[#E53935]">
            <strong>Catatan penolakan:</strong> {document.rejection_note}
          </div>
        )}
      </div>
    </div>
  );
}